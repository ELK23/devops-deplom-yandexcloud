variable "access_key" {}
variable "secret_key" {}
variable "cloud_id" {}
variable "folder_id" {}
variable "service_account_id" {}
variable "mysql_root_password" {
  description = "Password for MySQL root user"
  type        = string
}

variable "image_id" {
  description = "image ID"
  default = "fd8jfh73rvks3qlqp3ck"
}

variable "ssh_public_key" {
  description = "Public SSH key for ubuntu user"
  type        = string
  default     = ""
}