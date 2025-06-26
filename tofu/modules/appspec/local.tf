locals {
  raw = yamldecode(file(var.spec_path))
}
