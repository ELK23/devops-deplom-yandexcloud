resource "yandex_storage_bucket" "iam-bucket" {
  bucket     = "bucket-for-tfstate-vars"
  access_key = var.access_key
  secret_key = var.secret_key
  max_size = 1073741824
}
