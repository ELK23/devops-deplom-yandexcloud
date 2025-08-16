terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
#export ACCESS_KEY="<идентификатор_ключа>"
#export SECRET_KEY="<секретный_ключ>"

  #terraform init -backend-config="access_key=$ACCESS_KEY" -backend-config="secret_key=$SECRET_KEY"
  
   backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "bucket-for-tfstate-vars"
    region = "ru-central1"
    key = "terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  }
}



provider "yandex" {
  service_account_key_file = "/home/veer/key.json"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = "ru-central1-a"
  profile                  = "terraform"
}

