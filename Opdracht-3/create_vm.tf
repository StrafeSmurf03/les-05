provider "esxi" {
  esxi_hostname      = var.esxi_hostname
  esxi_hostport      = var.esxi_hostport
  esxi_hostssl       = var.esxi_hostssl
  esxi_username      = var.esxi_username
  esxi_password      = var.esxi_password
}

data "template_file" "Default" {
  template = file("userdata.tpl")
  vars = {
    ssh_user = var.ssh_username
    ssh_key = var.ssh_key
  }
}

resource "esxi_guest" "servers" {
  guest_name = "vm1"
  disk_store = "Local_Storage"  
  
  memsize  = "2048"
  numvcpus = "2"
  power    = "on"
  guestos = "Ubuntu"
  ovf_source        = var.ovf_file

  network_interfaces {
    virtual_network = "VM Network" 
  }
  guestinfo = {
    "userdata.encoding" = "gzip+base64"
    "userdata"          = base64gzip(data.template_file.Default.rendered)
    }
}

resource "local_file" "outputs" {
  content = <<-EOT
    [webservers]
    ${esxi_guest.servers.ip_address}

    [all:vars]
    ansible_ssh_user= ${var.ssh_username}
    ansible_ssh_private_key_file=/home/gebruiker/id_ed25519
    become_passwd=
  EOT
  filename = "${path.module}/inventory.ini"
}