
locals {
  fqdn = var.fqdn
  url = "https://${local.fqdn}/"
  auth0_config_secret_name_prefix = "oidc-config"
}

data auth0_tenant tenant {

}

resource "auth0_resource_server" "api" {
  name = "${var.api.name}-api"
  identifier = "https://${var.api.fqdn}"
  signing_alg = "RS256"

  allow_offline_access = true
  enforce_policies = true
  
  skip_consent_for_verifiable_first_party_clients = true

  token_dialect = "rfc9068_profile_authz"
  token_lifetime = 300
}

resource auth0_resource_server_scopes scopes {
  resource_server_identifier = auth0_resource_server.api.identifier

  dynamic scopes {
    for_each = var.api.scopes

    content {
      # Todo: description in manifest
      description = scopes.value
      name = scopes.value
    }
  }
}

resource "auth0_client" "client" {
  name = "${var.client.name}-client"
  app_type = "regular_web"
  custom_login_page_on = false
  is_first_party = true
  
  # URL from CDN FQDN, or from client FQDN?
  allowed_origins = [ local.url ]
  callbacks = [ "${local.url}callback" ]
  allowed_logout_urls = [ local.url ]
  web_origins = [ local.url ]

  oidc_conformant = true

  grant_types = [ 
    "authorization_code",
    "refresh_token"
  ]

  jwt_configuration {
    alg = "RS256"
    lifetime_in_seconds = 300
  }

  refresh_token {
    expiration_type = "expiring"
    rotation_type = "rotating"
    idle_token_lifetime = 60*60*8
    token_lifetime = 60*60*24
  }
}

resource random_string client_secret {
  length = 60
  special = true
  override_special = "_-+."
}

resource random_string secret {
  length = 60
  special = true
  override_special = "_-+."
}

resource "auth0_client_credentials" "credentials" {
  client_id = auth0_client.client.id

  authentication_method = "client_secret_post"
  client_secret = random_string.client_secret.result
}

resource auth0_client_grant client_grant {
  client_id = auth0_client.client.client_id
  audience = auth0_resource_server.api.identifier
  scopes = var.client.scopes
}

// todo: this needs to come from config
resource "auth0_connection" "auth0" {

  name = "app-api-connection"
  is_domain_connection = true
  strategy = "auth0"

  options {
    password_policy = "excellent"
    brute_force_protection = true
    enabled_database_customization = false
    import_mode = false
    requires_username = false
    disable_signup = false
    password_history {
      enable = true
      size = 3
    }
    password_complexity_options {
      min_length = 12
    }
    mfa {
      active = true
      return_enroll_settings = true
    }
  }
}

resource auth0_connection_clients connections {
  connection_id = auth0_connection.auth0.id
  enabled_clients = [ auth0_client.client.client_id ]
}

# data aws_iam_policy_document secret_resource_policy {
#   statement {
#     effect = "Allow"
#     principals {
#       type = "AWS"
#       identifiers = [ 
#         local. 
#       ]
#     }
#     actions = [ "secretsmanager:GetSecretValue" ]
#     resources = [ aws_secretsmanager_secret.auth0_config.arn ]
#   }
# }

resource random_string secret_name {
  length = 8
  special = false
  numeric = false
  upper = true
  lower = true
}

locals {
  auth0_config_secret_name = "${local.auth0_config_secret_name_prefix}-${random_string.secret_name.result}"
}

resource aws_secretsmanager_secret auth0_config {
  name = local.auth0_config_secret_name
}

resource aws_secretsmanager_secret_version auth0_config {
  secret_id = aws_secretsmanager_secret.auth0_config.id
  secret_string = jsonencode({
    authRequired = true
    auth0Logout = true
    baseURL = "https://${var.client.fqdn}"
    clientID = auth0_client.client.client_id
    issuerBaseURL = "https://${data.auth0_tenant.tenant.domain}"
    clientSecret = random_string.client_secret.result
    secret = random_string.secret.result
    authorizationParams = {
      response_type = "code"
      audience = "https://${var.api.fqdn}"
      scope = "openid profile email ${join(" ", var.api.scopes)}"
    }
  })
}

# resource aws_secretsmanager_secret_policy auth0_config {
#   secret_arn = aws_secretsmanager_secret.auth0_config.arn
#   policy = data.aws_iam_policy_document.secret_resource_policy.json
# }

# resource "auth0_log_stream" "aws_eventbridge" {
#   // single log stream per tenant???

#   name = "${var.name}-log-stream-aws-eventbridge"
#   type = "eventbridge"
#   status = "active"

#   sink {
#     aws_account_id = local.eventbridge_account
#     aws_region = local.eventbridge_region 
#   }
# }

# resource "auth0_role" "roles" {
#   // 

#   for_each = var.roles

#   name = each.key
# }

# resource auth0_user god {
#   // one user is created by default with full roles and perms

#   email = 
# }

# resource auth0_custom_domain custom_domain {
#   domain = "TODO"
#   type = "auth0_managed_certs"
# }

# resource auth0_custom_domain_verification custom_domain {
#   depends_on = [ aws_route53_record.auth_domain ]

#   custom_domain_id = auth0_custom_domain.custom_domain.id

#   timeouts {
#     create = "10m"
#   }
# }

# data aws_route53_zone root {
#   name = var.fqdn
# }

# resource aws_route53_record auth_domain {
#   hosted_zone = data.aws_route53_zone.root.id
  
# }

# resource "aws_verifiedpermissions_policy_store" "policy_store" {
#   validation_settings {
#     mode = "STRICT"
#   }
# }

# resource "aws_verifiedpermissions_schema" "schema" {
#   policy_store_id = aws_verifiedpermissions_policy_store.policy_store.policy_store_id

#   definition {
#     value = jsonencode({
#       "Namespace" : {
#         "entityTypes" : "???",
#         "actions" : local.actions
#       }
#     })
#   }
# }

# resource "aws_verifiedpermissions_identity_source" "identity_source" {
#   policy_store_id = aws_verifiedpermissions_policy_store.policy_store.id
#   configuration {
#     open_id_connect_configuration {
#       issuer = local.issuer
#       token_selection {
#         access_token_only {
#           audiences          = local.audiences
#           principal_id_claim = "sub"
#         }
#       }
#       entity_id_prefix = "MyOIDCProvider"
#       group_configuration {
#         group_claim       = "groups"
#         group_entity_type = "MyCorp::UserGroup"
#       }
#     }
#   }
#   principal_entity_type = "MyCorp::User"
# }
