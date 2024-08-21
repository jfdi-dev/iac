
locals {

}

resource "aws_cloudwatch_dashboard" "application" {
  dashboard_name = "${var.name}-application"

  dashboard_body = {
    start = "-PT12H"
    periodOverride = "auto"
    widgets = [
      
    ]
  }
}

resource "aws_cloudwatch_dashboard" "errors" {
  dashboard_name = "${var.name}-errors"

  dashboard_body = {
    start = "-PT12H"
    periodOverride = "auto"
    widgets = [
      
    ]
  }
}

resource "aws_cloudwatch_dashboard" "statics" {
  dashboard_name = "${var.name}-statics"

  dashboard_body = {
    start = "-PT12H"
    periodOverride = "auto"
    widgets = [
      
    ]
  }
}

resource "aws_cloudwatch_dashboard" "apis" {
  dashboard_name = "${var.name}-apis"

  dashboard_body = {
    start = "-PT12H"
    periodOverride = "auto"
    widgets = [
      
    ]
  }
}

resource "aws_cloudwatch_dashboard" "datastores" {
  dashboard_name = "${var.name}-datastores"

  dashboard_body = {
    start = "-PT12H"
    periodOverride = "auto"
    widgets = [
      
    ]
  }
}