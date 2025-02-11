#
# Datastore
# =========
#
# Disjoint union of:
# 
# - document-datastore
# - rdbms-datastore
#

module "document-dbs" {
  for_each = var.document

  source = "./document"

  name = each.key
  keys = each.value.keys
}

# module "relational-dbs" {
#   for_each = var.relational

#   source = "./relational"
# }