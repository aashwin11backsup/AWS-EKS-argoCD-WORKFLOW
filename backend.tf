terraform {
  backend "s3" {
    bucket         = "staging-eks-demo-tfstate-t1" # Replace with your bucket name
    key            = "staging/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "staging-eks-demo-tf-lock"    # Replace with your table name
  }
}