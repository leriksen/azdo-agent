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

variable "cloudinit" {
  type    = object({
    customized_attributes         = optional(map(string), {})
    customized_script             = optional(string     , "")
    customized_runcmd_script      = optional(string     , "")
    customized_write_files_script = optional(string     , "")
  })
  default = {}
}

variable "token" {
  type = string
}
