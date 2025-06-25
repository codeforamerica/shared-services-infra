locals {
  apps = {
    column-sandbox : yamldecode(file("${path.module}/apps/column-sandbox.yaml"))
    dc-sebt-portal : yamldecode(file("${path.module}/apps/dc-sebt-portal.yaml"))
    df-all-screens-scrape : yamldecode(file("${path.module}/apps/df-all-screens-scrape.yaml"))
  }
}
