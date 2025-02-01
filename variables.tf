variable "parameters" {

  type = object({
    vcenter                   = string
    vcenter_user              = string
    vcenter_password          = string
    vsphere_datacenter_target = string
    vsphere_datastore_target  = string
    vsphere_cluster_target    = string
    esxi_host_target          = string
    vsphere_portgroup_target  = string
    ova_name                  = string
    nestedcluster = object({
      nested_cluster_name = string
      esxi_dns            = string
      esxi_domain         = string
      esxi_syslog         = optional(string)
      esxi_netmask        = string
      esxi_gateway        = string
      hosts = map(object({
        esxi_cpu = number
        esxi_ram = number
        #for vapp
        esxi_hostname = string
        esxi_ip       = string
        esxi_password = string
        #end for vapp
        mdisks = optional(map(object({
          size = number
          id   = number
        })))
      }))
    })
  })
  description = "List of virtual machines to be deployed"
}










