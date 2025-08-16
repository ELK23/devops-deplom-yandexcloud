resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    nat       = true  # Внешний IP нужен для управления кластером
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "k8s_worker_b" {
  name        = "k8s-worker-b"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_b.id
    nat       = false  # NAT через шлюз
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "k8s_worker_d" {
  name        = "k8s-worker-d"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_d.id
    nat       = false
  }

  scheduling_policy {
    preemptible = true
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}