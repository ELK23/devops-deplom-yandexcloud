resource "yandex_iam_service_account" "sa" {
  name        = "limitone"
  description = "Limited user for terraform"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "editor_role" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}