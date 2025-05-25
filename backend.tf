terraform {
  backend "s3" {
    bucket = "terraform-tfstate--brahma"
    key = "k8s/terraform.tfstate"
    region = "us-east-1"
    
  }
}