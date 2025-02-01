parameters = {

  #vCenter credentials
  vcenter          = "VCENTER_IP_OR_HOSTNAME"
  vcenter_user     = "VCENTER_USER"
  vcenter_password = "VCENTER_PASSWORD"

  #Target environment ( existing one )
  vsphere_datacenter_target = "DATACENTER_NAME"
  vsphere_datastore_target  = "DATASTORE_NAME"
  vsphere_cluster_target    = "EXISTING_CLUSTER_NAME"
  esxi_host_target          = "ESXI_NAME"
  vsphere_portgroup_target  = "PORTGROUP_NAME"

  # OVA details
  ova_name   = "OVA_FILE_NAME" # OVA FILENAME WITHOUT THE EXTENSION

  #Nested cluster details and hosts details ( cluster and hosts which will be deployed)
  nestedcluster = {

    nested_cluster_name = "NESTED_CLUSTER_NAME"
    esxi_dns            = "DNS_IP"
    esxi_domain         = "DOMAIN_NAME"
    esxi_netmask        = "NETWORK_MASK"
    esxi_gateway        = "GATEWAY"
    hosts = {
      "esxi1" = {
        esxi_cpu      = "4"     # VIRTUAL ESXI CPUS
        esxi_ram      = "65536" # VIRTUAL ESXI RAM IN MB  
        esxi_hostname = "ESXI_HOSTNAME"
        esxi_ip       = "ESXI_IP"
        esxi_password = "ESXI_ROOT_PASSWORD "
        mdisks = { # DISKs AND SIZEs
          disk1 = {
            size = 100
            id   = 1
          }
          disk3 = {
            size = 100
            id   = 2
          }
        }
      }
      "esxi2" = {
        esxi_cpu      = "4"     # VIRTUAL ESXI CPUS
        esxi_ram      = "65536" # VIRTUAL ESXI RAM IN MB  
        esxi_hostname = "ESXI_HOSTNAME"
        esxi_ip       = "ESXI_IP"
        esxi_password = "ESXI_ROOT_PASSWORD "
        mdisks = { # DISKs AND SIZEs
          disk1 = {
            size = 100
            id   = 1
          }
          disk3 = {
            size = 100
            id   = 2
          }
        }
      }
    }
  }
}
