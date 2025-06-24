locals {
  apps = {
    dc-sebt-portal : yamldecode(file("${path.module}/apps/dc-sebt-portal.yaml"))
    df-all-screen-scrapes : yamldecode(file("${path.module}/apps/df-all-screens-scrape.yaml"))
  }
}
