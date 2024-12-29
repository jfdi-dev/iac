mock_provider "aws" {}
mock_provider "aws" {
  alias = "tls"
}

run "static_or_api_required" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
  }

  expect_failures = [
    var.api
  ]
}

run "static_or_nonempty_api_required" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = []
    api = []
  }

  expect_failures = [
    var.api
  ]
}

run "single_static_allowed" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = [
      {
        fqdn = "test.com"
      }
    ]
  }
}

run "single_api_only_allowed" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    api = [
      { 
        fqdn = "test.com"  
      }
    ]
  }
}

run "multiple_api_requires_prefixes" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    api = [
      {
        fqdn = "test.com"
      },
      {
        fqdn = "test2.com"
      }
    ]
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_api_allows_only_one_default" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    api = [
      {
        prefix = "t"
        fqdn = "test.com"
      },
      {
        fqdn = "test2.com"
      },
      {
        fqdn = "test2.com"
      }
    ]
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_api_requires_unique_prefixes" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    api = [
      {
        prefix = "t"
        fqdn = "test.com"
      },
      {
        prefix = "t"
        fqdn = "test2.com"
      }
    ]
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_api_with_unique_prefixes_allowed" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    api = [
      {
        prefix = "t"
        fqdn = "test.com"
      },
      {
        prefix = "t2"
        fqdn = "test2.com"
      }
    ]
  }
}

run "multiple_api_with_default_mount_allowed" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    api = [
      {
        fqdn = "www.test.com"
      },
      {
        prefix = "t"
        fqdn = "www.test2.com"
      }
    ]
  }
}

run "multiple_static_requires_prefixes" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = [
      {
        fqdn = "test.com"
      },
      {
        fqdn = "test2.com"
      }
    ]
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_static_allows_only_one_default" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = [
      {
        prefix = "t"
        fqdn = "test.com"
      },
      {
        fqdn = "test2.com"
      },
      {
        fqdn = "test2.com"
      }
    ]
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_static_requires_unique_prefixes" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = [
      {
        prefix = "t"
        fqdn = "test.com"
      },
      {
        prefix = "t"
        fqdn = "test2.com"
      }
    ]
  }

  expect_failures = [
    var.api
  ]
}

run "multiple_static_with_unique_prefixes_allowed" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = [
      {
        prefix = "t"
        fqdn = "test.com"
      },
      {
        prefix = "t2"
        fqdn = "test2.com"
      }
    ]
  }
}

run "multiple_static_with_default_mount_allowed" {
  command = plan

  variables {
    protected = false
    fqdn = "test.com"
    static = [
      {
        fqdn = "www.test.com"
      },
      {
        prefix = "t"
        fqdn = "www.test2.com"
      }
    ]
  }
}

