
locals {
  fqdn                            = var.fqdn
  url                             = "https://${local.fqdn}/"
  auth0_config_secret_name_prefix = "oidc-config"

  minutes = 60
  hours   = 60 * local.minutes

  access_token_lifetime           = 5 * local.minutes
  refresh_token_idle_lifetime     = 8 * local.hours
  refresh_token_absolute_lifetime = 24 * local.hours

  connections = {
    database : contains(var.connections, "database")
    google : contains(var.connections, "google")
    facebook : contains(var.connections, "facebook")
    apple : contains(var.connections, "apple")
    linkedin : contains(var.connections, "linkedin")
  }

  roles = coalesce(var.roles, tomap({}))
}

data "auth0_tenant" "tenant" {

}

resource "auth0_resource_server" "api" {
  name = "${var.api.name}-api"
  # again, this needs to come from CDN module or something...
  identifier  = "https://${local.fqdn}/api"
  signing_alg = "RS256"

  allow_offline_access = true
  enforce_policies     = true

  skip_consent_for_verifiable_first_party_clients = true

  token_dialect  = "rfc9068_profile_authz"
  token_lifetime = local.access_token_lifetime
}

resource "auth0_resource_server_scopes" "scopes" {
  resource_server_identifier = auth0_resource_server.api.identifier

  dynamic "scopes" {
    for_each = var.api.scopes

    content {
      # Todo: description in manifest
      description = scopes.value
      name        = scopes.value
    }
  }
}

resource "auth0_client" "client" {
  name                 = "${var.client.short_name}-client"
  app_type             = "regular_web"
  custom_login_page_on = false
  is_first_party       = true

  # URL from CDN FQDN, or from client FQDN?
  allowed_origins     = [local.url]
  callbacks           = ["${local.url}callback"]
  allowed_logout_urls = [local.url]
  web_origins         = [local.url]

  oidc_conformant = true

  grant_types = [
    "authorization_code",
    "refresh_token"
  ]

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = local.access_token_lifetime
  }

  refresh_token {
    expiration_type     = "expiring"
    rotation_type       = "rotating"
    idle_token_lifetime = local.refresh_token_idle_lifetime
    token_lifetime      = local.refresh_token_absolute_lifetime
  }
}

resource "random_string" "client_secret" {
  length           = 60
  special          = true
  override_special = "_-+."
}

resource "random_string" "secret" {
  length           = 60
  special          = true
  override_special = "_-+."
}

resource "auth0_client_credentials" "credentials" {
  client_id = auth0_client.client.id

  authentication_method = "client_secret_post"
  client_secret         = random_string.client_secret.result
}

resource "auth0_client_grant" "client_grant" {
  client_id = auth0_client.client.client_id
  audience  = auth0_resource_server.api.identifier
  scopes    = var.client.scopes
}

// todo: this needs to come from config
resource "auth0_connection" "database" {
  count = local.connections.database ? 1 : 0

  name                 = "${var.api.name}-database-connection"
  is_domain_connection = true
  strategy             = "auth0"

  options {
    password_policy                = "excellent"
    brute_force_protection         = true
    enabled_database_customization = false
    import_mode                    = false
    requires_username              = false
    disable_signup                 = var.disable_signup
    password_history {
      enable = true
      size   = 3
    }
    password_complexity_options {
      min_length = 12
    }
    mfa {
      active                 = true
      return_enroll_settings = true
    }
  }
}

# This is an example of a Google OAuth2 connection.

resource "auth0_connection" "google" {
  count = local.connections.google ? 1 : 0

  name     = "${var.client.short_name}-google-connection"
  strategy = "google-oauth2"

  options {
    client_id                = auth0_client.client.client_id
    client_secret            = random_string.client_secret.result
    allowed_audiences        = ["https://${local.fqdn}/api"]
    scopes                   = ["email", "profile"]
    set_user_root_attributes = "on_each_login"
    non_persistent_attrs     = ["ethnicity", "gender"]
  }
}

# This is an example of a Facebook connection.

resource "auth0_connection" "facebook" {
  count = local.connections.facebook ? 1 : 0

  name     = "${var.client.short_name}-facebook-connection"
  strategy = "facebook"

  options {
    client_id     = auth0_client.client.client_id
    client_secret = random_string.client_secret.result
    scopes = [
      "public_profile",
      "email",
    ]
    set_user_root_attributes = "on_each_login"
    non_persistent_attrs     = ["ethnicity", "gender"]
  }
}

# This is an example of an LinkedIn connection.

resource "auth0_connection" "linkedin" {
  count = local.connections.linkedin ? 1 : 0

  name     = "${var.client.short_name}-linkedin-connection"
  strategy = "linkedin"

  options {
    client_id                = auth0_client.client.client_id
    client_secret            = random_string.client_secret.result
    strategy_version         = 2
    scopes                   = ["basic_profile", "profile", "email"]
    set_user_root_attributes = "on_each_login"
    non_persistent_attrs     = ["ethnicity", "gender"]
  }
}

resource "auth0_connection_clients" "database" {
  count = local.connections.database ? 1 : 0

  connection_id   = auth0_connection.database[0].id
  enabled_clients = [auth0_client.client.client_id]
}

resource "auth0_connection_clients" "google" {
  count = local.connections.google ? 1 : 0

  connection_id   = auth0_connection.google[0].id
  enabled_clients = [auth0_client.client.client_id]
}

resource "auth0_connection_clients" "facebook" {
  count = local.connections.facebook ? 1 : 0

  connection_id   = auth0_connection.facebook[0].id
  enabled_clients = [auth0_client.client.client_id]
}

resource "auth0_connection_clients" "linkedin" {
  count = local.connections.linkedin ? 1 : 0

  connection_id   = auth0_connection.linkedin[0].id
  enabled_clients = [auth0_client.client.client_id]
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

resource "random_string" "secret_name" {
  length  = 8
  special = false
  numeric = false
  upper   = true
  lower   = true
}

locals {
  auth0_config_secret_name = "${local.auth0_config_secret_name_prefix}-${random_string.secret_name.result}"
}

resource "aws_secretsmanager_secret" "auth0_config" {
  name = local.auth0_config_secret_name
}

locals {
  issuer_fqdn     = var.dns.custom ? local.auth_fqdn : data.auth0_tenant.tenant.domain
  issuer_base_url = "https://${local.issuer_fqdn}"
}

resource "aws_secretsmanager_secret_version" "auth0_config" {
  secret_id = aws_secretsmanager_secret.auth0_config.id
  secret_string = jsonencode({
    authRequired  = true
    auth0Logout   = true
    baseURL       = "https://${local.fqdn}"
    clientID      = auth0_client.client.client_id
    issuerBaseURL = local.issuer_base_url
    clientSecret  = random_string.client_secret.result
    secret        = random_string.secret.result
    session = {
      rollingDuration = local.access_token_lifetime
    }
    authorizationParams = {
      response_type = "code"
      # This needs to be the public URL of the API...
      audience = "https://${local.fqdn}/api"
      scope    = "openid profile email ${join(" ", var.api.scopes)}"
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

resource "auth0_role" "roles" {
  for_each = local.roles

  name = each.key
}

resource "auth0_role_permissions" "role_permissions" {
  for_each = local.roles

  role_id = auth0_role.roles[each.key].id

  dynamic "permissions" {
    for_each = each.value
    content {
      name                       = permissions.value
      resource_server_identifier = auth0_resource_server.api.identifier
    }
  }
}

# resource auth0_user god {
#   // one user is created by default with full roles and perms

#   email = 
# }

locals {
  domain_parts             = split(".", var.fqdn)
  domain_without_subdomain = slice(local.domain_parts, 1, length(local.domain_parts))
  zone_name                = join(".", local.domain_without_subdomain)
  auth_fqdn                = "${var.dns.subdomain}.${local.zone_name}"
}

data "aws_route53_zone" "root_domain" {
  name         = local.zone_name
  private_zone = false
}

resource "auth0_custom_domain" "custom_domain" {
  count  = var.dns.custom ? 1 : 0
  domain = local.auth_fqdn
  type   = "auth0_managed_certs"
}

resource "aws_route53_record" "auth_domain" {
  count   = var.dns.custom ? 1 : 0
  zone_id = data.aws_route53_zone.root_domain.zone_id
  name    = local.auth_fqdn
  type    = upper(auth0_custom_domain.custom_domain[0].verification[0].methods[0].name)
  ttl     = var.dns.ttl
  records = [auth0_custom_domain.custom_domain[0].verification[0].methods[0].record]

  lifecycle {
    precondition {
      condition     = length(auth0_custom_domain.custom_domain) > 0 && length(auth0_custom_domain.custom_domain[0].verification) > 0
      error_message = "Resource `auth0_custom_domain.custom_domain did not match expected schema: (${jsonencode(auth0_custom_domain.custom_domain)})"
    }
  }
}

resource "auth0_custom_domain_verification" "custom_domain" {
  count = var.dns.custom ? 1 : 0

  depends_on = [aws_route53_record.auth_domain[0]]

  custom_domain_id = auth0_custom_domain.custom_domain[0].id

  timeouts {
    create = "10m"
  }
}

# This can either get deleted or moved to an `avp/` dir?

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
