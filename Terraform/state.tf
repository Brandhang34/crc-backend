terraform {
  backend "s3" {
    bucket = "brandonhang.co-terraform-state-file"
    key    = "portfolio-terraform-state-file"
    region = "us-east-1"
  }
}

