provider "lxc" {}

variable "control_count" {
  default = "3" 
}

variable "edge_count" { 
  default = "2" 
}

variable "worker_count" { 
  default = "3" 
}

variable "template_name" {
  default = "ubuntu"
}

variable "template_release" {
  default = "trusty"
}

variable "template_arch" {
  default = "amd64"
}

resource "lxc_bridge" "my_bridge" {
  name = "my_bridge"
}

variable "ips" {
  default = {
    "0" = "192.168.255.1/24"
    "1" = "192.168.255.2/24"
    "2" = "192.168.255.3/24"
  }
}

resource "lxc_container" "control" {
  count = "${var.control_count}"
  template_name = "${var.template_name}"
  template_release = "${var.template_release}"
  template_arch = "${var.template_arch}"
  template_extra_args = ["--auth-key", "/root/.ssh/id_rsa.pub"]
  name = "control-${format("%02d",count.index+1)}"
  network_interface {
    type = "veth"
    options {
      link = "lxcbr0"
      flags = "up"
     hwaddr = "00:16:3e:xx:xx:xx"
    }
  }

  network_interface {
    type = "veth"
    options {
      link = "${lxc_bridge.my_bridge.name}"
      flags = "up"
      ipv4 = "${lookup(var.ips, count.index)}"
    }
  }
}


resource "lxc_container" "worker" {
  count = "${var.worker_count}"
  template_name = "${var.template_name}"
  template_release = "${var.template_release}"
  template_arch = "${var.template_arch}"
  template_extra_args = ["--auth-key", "/root/.ssh/id_rsa.pub"]
  name = "worker-${format("%02d",count.index+1)}"
}
