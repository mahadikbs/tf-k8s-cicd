terraform {
  backend "s3" {
    bucket = "value"
    key = "k8s/terraform.tfstate"
    region = "us-east-1"
    
  }
}