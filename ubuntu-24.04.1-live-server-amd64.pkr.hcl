source "proxmox-iso" "ubuntu-server-noble-numbat" {
  proxmox_url              = var.proxmox_api_host
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  node                 = "proxmox"
  template_name        = "ubuntu-24.04.1-live-server-amd64-template-${formatdate("YYYYMMDD", timestamp())}"
  template_description = "Ubuntu Server Image 24.04.1 LTS generated on ${timestamp()}"

  iso_url          = "http://se.releases.ubuntu.com/noble/ubuntu-24.04.1-live-server-amd64.iso"
  iso_checksum     = "e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  iso_storage_pool = "local"
  unmount_iso      = true

  qemu_agent      = true
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "30G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  cpu_type = "host"
  cores    = "2"
  memory   = "2048"
  os       = "l26"

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  boot         = "c"
  boot_wait    = "10s"
  communicator = "ssh"

  http_directory = "http"
  ssh_agent_auth = true
  ssh_username   = "lillt"
  ssh_password   = "lillt"
  ssh_timeout    = "30m"
  ssh_pty        = true
}

build {
  name    = "ubuntu-server-noble-numbat"
  sources = ["source.proxmox-iso.ubuntu-server-noble-numbat"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }
}
