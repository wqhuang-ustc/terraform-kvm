provider "libvirt" {
   uri   = "qemu:///system"
}

resource "libvirt_pool" "ubuntu" {
  name = "ubuntu"
  type = "dir"
  path = "/var/lib/libvirt/terraform-provider-libvirt-pool-ubuntu-preview"
}

resource "libvirt_volume" "ubuntu" {
  name = "ubuntu"
  pool = libvirt_pool.ubuntu.name
  source = "/root/preview/terraform-kvm/bionic-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "master1-qcow2" {
  name = "master1.qcow2"
  pool = libvirt_pool.ubuntu.name
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}

resource "libvirt_volume" "master2-qcow2" {
  name = "master2.qcow2"
  pool = libvirt_pool.ubuntu.name
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}

resource "libvirt_volume" "master3-qcow2" {
  name = "master3.qcow2"
  pool = libvirt_pool.ubuntu.name
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}

resource "libvirt_volume" "node1-qcow2" {
  name = "node1.qcow2"
  pool = libvirt_pool.ubuntu.name
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}

resource "libvirt_volume" "node2-qcow2" {
  name = "node2.qcow2"
  pool = libvirt_pool.ubuntu.name
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}

resource "libvirt_volume" "node3-qcow2" {
  name = "node3.qcow2"
  pool = libvirt_pool.ubuntu.name
  base_volume_id = libvirt_volume.ubuntu.id
  format = "qcow2"
}


data "template_file" "user_data_master1" {
  template = file("${path.module}/cloud_init_master1.cfg")
}

data "template_file" "user_data_master2" {
  template = file("${path.module}/cloud_init_master2.cfg")
}

data "template_file" "user_data_master3" {
  template = file("${path.module}/cloud_init_master3.cfg")
}

data "template_file" "user_data_node1" {
  template = file("${path.module}/cloud_init_node1.cfg")
}

data "template_file" "user_data_node2" {
  template = file("${path.module}/cloud_init_node2.cfg")
}

data "template_file" "user_data_node3" {
  template = file("${path.module}/cloud_init_node3.cfg")
}

data "template_file" "network_config_master1" {
  template = file("${path.module}/network_config_master1.cfg")
}

data "template_file" "network_config_master2" {
  template = file("${path.module}/network_config_master2.cfg")
}

data "template_file" "network_config_master3" {
  template = file("${path.module}/network_config_master3.cfg")
}

data "template_file" "network_config_node1" {
  template = file("${path.module}/network_config_node1.cfg")
}

data "template_file" "network_config_node2" {
  template = file("${path.module}/network_config_node2.cfg")
}

data "template_file" "network_config_node3" {
  template = file("${path.module}/network_config_node3.cfg")
}


# Use CloudInit to init the instance
resource "libvirt_cloudinit_disk" "master1-commoninit" {
  name = "master1-commoninit.iso"
  pool = libvirt_pool.ubuntu.name
  user_data = data.template_file.user_data_master1.rendered
  network_config = data.template_file.network_config_master1.rendered
}

resource "libvirt_cloudinit_disk" "master2-commoninit" {
  name = "master2-commoninit.iso"
  pool = libvirt_pool.ubuntu.name
  user_data = data.template_file.user_data_master2.rendered
  network_config = data.template_file.network_config_master2.rendered
}

resource "libvirt_cloudinit_disk" "master3-commoninit" {
  name = "master3-commoninit.iso"
  pool = libvirt_pool.ubuntu.name
  user_data = data.template_file.user_data_master3.rendered
  network_config = data.template_file.network_config_master3.rendered
}


resource "libvirt_cloudinit_disk" "node1-commoninit" {
  name = "node1-commoninit.iso"
  pool = libvirt_pool.ubuntu.name
  user_data = data.template_file.user_data_node1.rendered
  network_config = data.template_file.network_config_node1.rendered
}

resource "libvirt_cloudinit_disk" "node2-commoninit" {
  name = "node2-commoninit.iso"
  pool = libvirt_pool.ubuntu.name
  user_data = data.template_file.user_data_node2.rendered
  network_config = data.template_file.network_config_node2.rendered
}

resource "libvirt_cloudinit_disk" "node3-commoninit" {
  name = "node3-commoninit.iso"
  pool = libvirt_pool.ubuntu.name
  user_data = data.template_file.user_data_node3.rendered
  network_config = data.template_file.network_config_node3.rendered
}


# Define KVM domain to create
resource "libvirt_domain" "master1" {
  name   = "master1"
  memory = "8192"
  vcpu   = 4
  qemu_agent = true
  autostart = true

  network_interface {
    hostname = "master1_network"
    bridge = "br0"
  }

  disk {
    volume_id = libvirt_volume.master1-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.master1-commoninit.id


  # Important
  # ubuntu can hang is a isa-serial is not present at boot time.
  # if you find your cpu 100% and never is available this is why
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "master2" {
  name   = "master2"
  memory = "8192"
  vcpu   = 4
  qemu_agent = true
  autostart = true

  network_interface {
    hostname = "master2_network"
    bridge = "br0"
  }

  disk {
    volume_id = libvirt_volume.master2-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.master2-commoninit.id


  # Important
  # ubuntu can hang is a isa-serial is not present at boot time.
  # if you find your cpu 100% and never is available this is why
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "master3" {
  name   = "master3"
  memory = "8192"
  vcpu   = 4
  qemu_agent = true
  autostart = true

  network_interface {
    hostname = "master3_network"
    bridge = "br0"
  }

  disk {
    volume_id = libvirt_volume.master3-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.master3-commoninit.id


  # Important
  # ubuntu can hang is a isa-serial is not present at boot time.
  # if you find your cpu 100% and never is available this is why
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "node1" {
  name   = "node1"
  memory = "8192"
  vcpu   = 4
  qemu_agent = true
  autostart = true

  network_interface {
    hostname = "node1-network"
    bridge = "br0"
  }


  disk {
    volume_id = libvirt_volume.node1-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.node1-commoninit.id


  # Important
  # ubuntu can hang is a isa-serial is not present at boot time.
  # if you find your cpu 100% and never is available this is why
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "node2" {
  name   = "node2"
  memory = "8192"
  vcpu   = 4
  qemu_agent = true
  autostart = true

  network_interface {
    hostname = "node2-network"
    bridge = "br0"
  }

  disk {
    volume_id = libvirt_volume.node2-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.node2-commoninit.id


  # Important
  # ubuntu can hang is a isa-serial is not present at boot time.
  # if you find your cpu 100% and never is available this is why
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "node3" {
  name   = "node3"
  memory = "8192"
  vcpu   = 4
  qemu_agent = true
  autostart = true

  network_interface {
    hostname = "node3-network"
    bridge = "br0"
  }


  disk {
    volume_id = libvirt_volume.node3-qcow2.id
  }

  cloudinit = libvirt_cloudinit_disk.node3-commoninit.id


  # Important
  # ubuntu can hang is a isa-serial is not present at boot time.
  # if you find your cpu 100% and never is available this is why
  console {
    type = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }
  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}



terraform {
  required_version = ">= 0.12"
}
