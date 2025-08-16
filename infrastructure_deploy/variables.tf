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
  description = "ID публичного образа (например, Ubuntu 22.04)"
}