data "aws_vpc" "main" {
  tags = {
    Role = "main"
  }
}
