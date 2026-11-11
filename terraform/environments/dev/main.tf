locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Modules (vpc, eks, ecr, rds, dns, secrets, observability) are wired in by later epics.
