mock_provider "aws" {
  
}

run "x" {
  command = plan

  variables {
    document = {
      test = {
        keys = {
          hash = {
            name = "hk"
            type = "S"
          }
          range = {
            name = "rk"
            type = "S"
          }
        }
      }
    }
  }

  assert {
    condition = length(output.document-dbs) == 1
    error_message = "Expected a document db to be output, but wasn't"
  }
}