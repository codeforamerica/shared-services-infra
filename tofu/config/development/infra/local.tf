locals {
  apps = {
    sebt : yamldecode(file("${path.module}/apps/dc-sebt-portal.yaml"))
  }
}
