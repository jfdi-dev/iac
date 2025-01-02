mock_provider "aws" {
  alias = "main"
  mock_data "aws_route53_zone" {
    defaults = {
      name = "test.com"
      arn = "arn:aws:route53:::zone/test.com"
      zone_id = "abcdefg"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "aws" {
  alias = "tls"
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:::cert/my-cert"
      domain_validation_options = [
        {
          domain_name = "test.com"
          resource_record_name = "my.test.com"
          resource_record_value = "my.test.com"
          resource_record_type = "A"
        }
      ]
    }
  }
}

run "static_or_api_required" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
  }

  expect_failures = [
    var.api
  ]
}

run "static_or_nonempty_api_required" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    static = {}
    api = {}
  }

  expect_failures = [
    var.api
  ]
}

run "single_static_allowed" {
  command = apply

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "my.test.com"
    static = { 
      ui = {
        fqdn = "test.com"
        bucket_name = "test.com"
      }
    }
    
  }
}

run "single_api_only_allowed" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "my.test.com"
    api = {
      app = {
        fqdn = "test.com"  
      }
    }
  }
}

run "multiple_api_requires_prefixes" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "my.test.com"
    api = {
      one = {
        fqdn = "test.com"
      },
      two = {
        fqdn = "test2.com"
      }
    }
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_api_allows_only_one_default" {
  command = plan
  
  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    api = {
      one = {
        prefix = "t"
        fqdn = "test.com"
      },
      two = {
        fqdn = "test2.com"
      },
      three = {
        fqdn = "test2.com"
      }
    }
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_api_requires_unique_paths" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    api = {
      one = {
        path = "t"
        fqdn = "test.com"
      },
      two = {
        path = "t"
        fqdn = "test2.com"
      }
    }
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_api_with_unique_paths_allowed" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    api = {
      one = {
        path = "t"
        fqdn = "test.com"
      },
      two = {
        path = "t2"
        fqdn = "test2.com"
      }
    }
  }
}

run "multiple_api_with_default_mount_allowed" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    api = {
      one = {
        fqdn = "www.test.com"
      },
      two = {
        path = "t"
        fqdn = "www.test2.com"
      }
    }
  }
}

run "multiple_static_requires_paths" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    static = {
      one = {
        fqdn = "test.com"
        bucket_name = "test.com"
      },
      two = {
        fqdn = "test2.com"
        bucket_name = "test2.com"
      }
    }
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_static_allows_only_one_default" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    static = {
      one = {
        path = "t"
        fqdn = "test.com"
        bucket_name = "test.com"
      },
      two = {
        fqdn = "test2.com"
        bucket_name = "test2.com"
      },
      three = {
        fqdn = "test2.com"
        bucket_name = "test3.com"
      }
    }
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_static_requires_unique_paths" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    static = {
      one = {
        path = "t"
        fqdn = "test.com"
        bucket_name = "test.com"        
      },
      two = {
        path = "t"
        fqdn = "test2.com"
        bucket_name = "test2.com"        
      }
    }
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_static_with_unique_prefixes_allowed" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    static = {
      one = {
        path = "t"
        fqdn = "test.com"
        bucket_name = "test.com"
      },
      two = {
        path = "t2"
        fqdn = "test2.com"
        bucket_name = "test2.com"
      }
    }
  }
}

run "multiple_static_with_default_mount_allowed" {
  command = plan

  providers = {
    aws = aws.main
    aws.tls = aws.tls
  }

  variables {
    fqdn = "test.com"
    static = {
      one = {
        fqdn = "www.test.com"
        bucket_name = "www.test.com"
      },
      two = {
        path = "t"
        fqdn = "www.test2.com"
        bucket_name = "www.test2.com"
      }
    }
  }
}

