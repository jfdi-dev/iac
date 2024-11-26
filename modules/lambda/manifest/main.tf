
locals {
  yml_manifest_file = "manifest.yml"
  yaml_manifest_file = "manifest.yaml"
  json_manifest_file = "manifest.json"
  # Take directory path from handler
  p0 = dirname(var.path)
  # Split directory path into parts
  p1 = compact(split("/", var.path))
  # Construct list of all directory paths in hierarchy
  p2 = [ for idx, part in local.p1: slice(local.p1, 0, idx+1) ]
  p3 = [ for parts in local.p2: "${join("/", parts)}/" ]
  # Load all manifests in the directory hierarchy, whether yaml or json
  p4 = [ 
    for path in local.p3: 
      fileexists("${path}${local.yml_manifest_file}") ? 
        yamldecode(file("${path}${local.yml_manifest_file}")) :
          fileexists("${path}${local.yaml_manifest_file}") ? 
            yamldecode(file("${path}${local.yaml_manifest_file}")) :
              fileexists("${path}${local.json_manifest_file}") ? 
                jsondecode(file("${path}${local.json_manifest_file}")) :
                  null
  ]
  # Prepend defaults
  pX = concat([ var.defaults ], local.p4)
  # Remove all nulls (ie: no manifest exists at that directory in hierarchy)
  # (Compact only works with list(string) types)
  p5 = [ 
    for manifest in local.pX: manifest
    if manifest != null
  ]
  # Every property is an object/list, and Terraform `merge` is not deep.
  # So, we need to explicitly merge/concat each property...
  runtime = merge({}, [ 
    for manifest in local.p5: manifest.runtime
    if contains(keys(manifest), "runtime")    
  ]...)
  concurrency = merge({}, [
    for manifest in local.p5: manifest.concurrency
    if contains(keys(manifest), "concurrency")
  ]...)
  policies = merge({
    managed: []
    named: []
    custom: {}
  }, [
    for manifest in local.p5: manifest.policies
    if contains(keys(manifest), "policies")
  ]...)
  # Construct final manifest
  manifest = {
    runtime = local.runtime
    concurrency = local.concurrency
    policies = local.policies
  }
}