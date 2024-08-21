
locals {

}

resource "auth0_resource_server" "api" {
  for_each = var.apis

  name = "${each.key}-api"
  identifier = "${each.value.fqdn}"
  signing_alg = "RS256"

  allow_offline_access = true
  enforce_policies = true
  
  skip_consent_for_verifiable_first_party_clients = true

  token_dialect = "rfc9068_profile_authz"
  token_lifetime = 300
}

resource "auth0_client" "client" {
  for_each = var.statics

  name = "${each.key}-client"
  app_type = "regular_web"
  custom_login_page_on = false
  is_first_party = true
  
  allowed_origins = [ var.fqdn ]
  callbacks = [ var.fqdn ]
  allowed_logout_urls = [ var.fqdn ]
  web_origins = [ var.fqdn ]

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

resource "auth0_connection" "auth0" {
  name = "${var.name}-connection"
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

resource "auth0_log_stream" "aws_eventbridge" {
  name = "${var.name}-log-stream-aws-eventbridge"
  type = "eventbridge"
  status = "active"

  sink {
    aws_account_id = var.aws_eventbridge_account_id
    aws_region = var.aws_eventbridge_region
  }
}

resource "auth0_role" "roles" {
  for_each = var.roles

  name = each.key
}

resource "aws_verifiedpermissions_policy_store" "policy_store" {
  validation_settings {
    mode = "STRICT"
  }
}

resource "aws_verifiedpermissions_schema" "schema" {
  policy_store_id = aws_verifiedpermissions_policy_store.policy_store.policy_store_id

  definition {
    value = jsonencode({
      "Namespace" : {
        "entityTypes" : "???",
        "actions" : local.actions
      }
    })
  }
}

resource "aws_verifiedpermissions_identity_source" "identity_source" {
  policy_store_id = aws_verifiedpermissions_policy_store.policy_store.id
  configuration {
    open_id_connect_configuration {
      issuer = local.issuer
      token_selection {
        access_token_only {
          audiences          = local.audiences
          principal_id_claim = "sub"
        }
      }
      entity_id_prefix = "MyOIDCProvider"
      group_configuration {
        group_claim       = "groups"
        group_entity_type = "MyCorp::UserGroup"
      }
    }
  }
  principal_entity_type = "MyCorp::User"
}
