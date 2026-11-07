variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "admin_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}