locals {

  # Environment-based CIDR mapping
  cidr_map = {
    dev = {
      subnet   = "10.10.0.0/20"
      pods     = "10.20.0.0/16"
      services = "10.30.0.0/20"
    }

    prod = {
      subnet   = "10.40.0.0/20"
      pods     = "10.50.0.0/16"
      services = "10.60.0.0/20"
    }
  }

  # fallback for feature branches
  default_cidr = {
    subnet   = "10.70.0.0/20"
    pods     = "10.80.0.0/16"
    services = "10.90.0.0/20"
  }

  selected_cidr = lookup(local.cidr_map, var.environment, local.default_cidr)

  subnet_cidr   = local.selected_cidr.subnet
  pods_cidr     = local.selected_cidr.pods
  services_cidr = local.selected_cidr.services
}
