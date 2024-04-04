output "cloudinit" {
  sensitive = true
  value     = local.cloudinit
}

output "build_json" {
  value = local.build_json
}