resource "yandex_storage_bucket" "iam-bucket" {
  bucket     = "bucket-for-tfstate-vars"
  access_key = var.access_key
  secret_key = var.secret_key
  max_size = 1073741824
}

# resource "yandex_storage_object" "image" {
#   bucket     = yandex_storage_bucket.image_bucket.bucket
#   key        = "image.jpg"
#   source     = "files/image.jpg"
#   access_key = var.access_key
#   secret_key = var.secret_key
#   acl        = "public-read"
# }

#resource "yandex_storage_bucket" "test" {
 # bucket     = "lamp-demo-bucket-202506132"
 # access_key = var.access_key
 # secret_key = var.secret_key
 #
#}

