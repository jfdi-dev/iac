#
# Datastore
# =========
#
# Disjoint union of:
# 
# - document-datastore
# - rdbms-datastore
#

module "document-db" {
  count = var.document != null ? 1 : 0

  source = "./document"
}

module "rdbms-db" {
  count = var.rdbms != null ? 1 : 0

  source = "./rdbms"
}