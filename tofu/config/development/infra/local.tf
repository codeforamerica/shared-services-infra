locals {
  apps = {
    dc-sebt-portal : yamldecode(file("${path.module}/apps/dc-sebt-portal.yaml"))
  }
}
