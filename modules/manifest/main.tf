
# 
# `Manifest`
# ==========
#
# Given a file path (relative to root module), reads the file as a yaml / json file and makes the resulting object available as output.
#

locals {
  manifest_contents = file(var.path)
  is_yaml           = endswith(var.path, ".yaml") || endswith(var.path, ".yml")
  is_json           = endswith(var.path, ".json")
  manifest          = local.is_yaml ? try(yamldecode(local.manifest_contents), null) : local.is_json ? try(jsondecode(local.manifest_contents), null) : var._fail_on_error ? file("ERROR: Could not figure out type of manifest ('${var.path}' is not yml/yaml/json file..?)") : null

  manifest_ok = local.manifest != null ? true : var._fail_on_error ? file("ERROR: Failed to parse manifest") : false
}