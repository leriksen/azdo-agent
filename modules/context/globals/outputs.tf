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
    "8080",
    "8081",
    "80",
    "443",
    "1443",
    "22"
  ]
}