variable "ARM_CLIENT_ID" {
  type = string
}

variable "ARM_CLIENT_SECRET" {
  type = string
}

variable "ARM_TENANT_ID" {
  type = string
}

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}

variable "ssh_pub" {
  type = string
}

variable "app_tier" {
  type    = string
  default = "A"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "token" {
  type = string
}
