module "environment" {
  source      = "../modules/context/environment"
  environment = "dev"
}

module "subscription" {
  source = "../modules/context/subscription"
  subscription = module.environment.env_sub
}

module "global" {
  source = "../modules/context/globals"
}