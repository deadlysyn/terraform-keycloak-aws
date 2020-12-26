variable "private_cidr" {
  description = "RFC1918 CIDR range for private subnets (subset of vpc_cidr)"
  type        = string
}

variable "public_cidr" {
  description = "RFC1918 CIDR range for public subnets (subset of vpc_cidr)"
  type        = string
}

variable "tags" {
  description = "Tags applied to AWS resources"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "RFC1918 CIDR range for VPC"
  type        = string
}
