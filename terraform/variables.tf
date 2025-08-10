variable "region" {
  default = "eu-west-1"
}

variable "db_password" {
  description = "Password for MySQL"
  type        = string
}

variable "key_name" {
  description = "Name of existing EC2 key pair"
  type        = string
}
