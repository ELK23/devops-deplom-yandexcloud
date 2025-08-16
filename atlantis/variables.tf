variable "github_user" {
  description = "GitHub username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository (org/repo)"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "webhook_secret" {
  description = "Webhook secret for GitHub"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Base domain for ingress"
  type        = string
}