module "globals" {
  source = "../globals"
}

locals {
  as_string = {
    NP = "Non-Production"
    P  = "Production"
  }

  purpose = {
    NP = "non-prd"
    P  = "prd"
  }
}
