locals {
  role = {
    "A" = "App"
    "D" = "DB"
    "W" = "Web"
  }

  build_json = templatefile("${path.module}/templates/build.json.tmpl", {
    role        = local.role[upper(var.app_tier)]
    environment = upper(var.environment)
  })

  ado_cloud_init_script = templatefile("${path.module}/templates/customized_cloud_init_runcmd_script.yaml.tmpl", {
    token = azurerm_key_vault_secret.token.value
  })

  cloudinit = templatefile("${path.module}/templates/cloud-config.yaml.tmpl", {
    build_json_b64                           = base64encode(local.build_json)
    customized_cloud_init_script             = var.cloudinit.customized_script
#    customized_cloud_init_runcmd_script      = var.cloudinit.customized_runcmd_script
    customized_cloud_init_runcmd_script      = local.ado_cloud_init_script
    customized_cloud_init_write_files_script = var.cloudinit.customized_write_files_script
  })
}
