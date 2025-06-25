locals {
  apps = {
    dc-sebt-portal : yamldecode(file("${path.module}/apps/dc-sebt-portal.yaml"))
    df-all-screens-scrape : yamldecode(file("${path.module}/apps/df-all-screens-scrape.yaml"))
  }
}
