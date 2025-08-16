output "k8s_master_public_ip" {
  value = yandex_compute_instance.k8s_master.network_interface[0].nat_ip_address
}

output "k8s_master_private_ip" {
  value = yandex_compute_instance.k8s_master.network_interface[0].ip_address
}

output "k8s_worker_b_ip" {
  value = yandex_compute_instance.k8s_worker_b.network_interface[0].ip_address
}

output "k8s_worker_d_ip" {
  value = yandex_compute_instance.k8s_worker_d.network_interface[0].ip_address
}