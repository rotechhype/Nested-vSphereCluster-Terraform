provider "vsphere" {
  user                 = var.parameters.vcenter_user
  password             = var.parameters.vcenter_password
  vsphere_server       = var.parameters.vcenter
  allow_unverified_ssl = true
  api_timeout          = 10
}
provider "time" {
  # Configuration options
}
data "vsphere_datacenter" "datacenter" {
  name = var.parameters.vsphere_datacenter_target
}

data "vsphere_datastore" "datastore" {
  name          = var.parameters.vsphere_datastore_target
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.parameters.vsphere_cluster_target
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.parameters.esxi_host_target
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.parameters.vsphere_portgroup_target
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


## Local OVF/OVA Source
data "vsphere_ovf_vm_template" "ovfLocal" {
  name              = var.parameters.ova_name
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = "ova/${var.parameters.ova_name}.ova"
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network.id
  }
}

#Create the nested cluster
resource "vsphere_compute_cluster" "compute_cluster" {
  name               = var.parameters.nestedcluster.nested_cluster_name
  datacenter_id      = data.vsphere_datacenter.datacenter.id
  vsan_enabled       = true
  vsan_esa_enabled   = true
  vsan_unmap_enabled = true
  #vsan_performance_enabled = true
  drs_enabled          = true
  drs_automation_level = "fullyAutomated"
  host_managed         = true
  ha_enabled           = false
}

## Deployment of VM from Local OVF
resource "vsphere_virtual_machine" "vmFromLocalOvf" {
  for_each          = var.parameters.nestedcluster.hosts
  name              = each.value.esxi_hostname
  datacenter_id     = data.vsphere_datacenter.datacenter.id
  datastore_id      = data.vsphere_datastore.datastore.id
  resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
  host_system_id    = data.vsphere_host.host.id
  num_cpus          = each.value.esxi_cpu
  memory            = each.value.esxi_ram
  guest_id          = data.vsphere_ovf_vm_template.ovfLocal.guest_id
  firmware          = data.vsphere_ovf_vm_template.ovfLocal.firmware
  scsi_type         = data.vsphere_ovf_vm_template.ovfLocal.scsi_type
  nested_hv_enabled = true

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
  disk {
    label          = "disk0"
    unit_number    = 0
    size           = 16
    io_share_count = 1000
  }
  dynamic "disk" {
   # for_each = each.value.mdisks
  for_each = each.value.mdisks  != null ? each.value.mdisks : {}
    content {
      label          = "disk${disk.value.id}"
      unit_number    = disk.value.id
      size           = disk.value.size
      datastore_id   = data.vsphere_datastore.datastore.id
      io_share_count = 1000
    }
  }

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = false
    local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal.local_ovf_path
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map

  }
  vapp {
    properties = {  # all below are working
      "guestinfo.hostname"  = each.value.esxi_hostname,  
      "guestinfo.ipaddress" = each.value.esxi_ip, 
      "guestinfo.netmask"   = var.parameters.nestedcluster.esxi_netmask, 
      "guestinfo.gateway"   = var.parameters.nestedcluster.esxi_gateway, 
      "guestinfo.dns"       = var.parameters.nestedcluster.esxi_dns, 
      "guestinfo.domain"    = var.parameters.nestedcluster.esxi_domain, 
      "guestinfo.password"  = each.value.esxi_password,
      "guestinfo.syslog"    = var.parameters.nestedcluster.esxi_syslog 
    }
  }
  lifecycle {
    ignore_changes = [
      vapp[0].properties,
    ]
  }
}

#Sleep resource to wait for nested ESXis to be deployed
resource "time_sleep" "wait_300_seconds" {
  depends_on      = [vsphere_virtual_machine.vmFromLocalOvf]
  for_each        = vsphere_virtual_machine.vmFromLocalOvf
  create_duration = "200s"

}

#Get thumbprint for nested ESXis
data "vsphere_host_thumbprint" "thumbprint" {
  depends_on = [time_sleep.wait_300_seconds]
  for_each   = vsphere_virtual_machine.vmFromLocalOvf
  address    = each.value.name
  insecure   = true
}

#Add nested ESXis to vCenter and into cluster
resource "vsphere_host" "esx_nested" {
  for_each   = var.parameters.nestedcluster.hosts
  depends_on = [data.vsphere_host_thumbprint.thumbprint]
  hostname   = "${each.value.esxi_hostname}.${var.parameters.nestedcluster.esxi_domain}"
  username   = "root"
  password   = "parolaPASS33!"
  thumbprint = data.vsphere_host_thumbprint.thumbprint[each.key].id
  cluster    = vsphere_compute_cluster.compute_cluster.id
  lifecycle {
    ignore_changes = [thumbprint]
  }
  services {
    ntpd {
      enabled     = true
      policy      = "on"
      ntp_servers = ["pool.ntp.org"]
    }
  }
}
