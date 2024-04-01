output "tags" {
  value = {
    project      = "PE"
    project_code = "PE001"
    costcentre   = "00001"
  }
}

output location {
  value = "australiasoutheast"
}

output "ado_control_ports" {
  value = [
    "22",  # SSH
  ]
}
