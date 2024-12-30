
provider "aws" {

}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

module "petstore_app" {
  source = "../modules/root/domain-service"

  role = ""

  providers = {
    aws.tls  = aws.virginia
    aws.edge = aws.virginia
  }

  # fqdn                    = "app.jfdi.jaskwa.com"
  # protected               = false
  # disaster_recovery_level = "bronze"

  # statics = {
  #   app = {
  #     path = "*"
  #     src  = "./src/static/"
  #   }
  # }

  # apis = {
  #   petstore = {
  #     # type = "rest"
  #     path = "*"
  #     src  = "./src/api/"
  #     spec = "petstore_spec.yaml"
  #   }
  # }

  # datastores = {
  #   pets = {
  #     type = "rdbms"
  #     src  = "./src/db"
  #   }
  # }
}