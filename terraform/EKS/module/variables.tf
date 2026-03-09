variable "cluster_name" {}

variable "cidr_block" {}

variable "vpc_name" {}

variable "env" {}

variable "igw_name" {}

variable "pub_subnet_count" {}

variable "pub_cidr_block" {
  type = list(string)
}

variable "jump_instance_type" {
  default = "t3.micro"
}

variable "jump_key_name" {
  default = "eks-key-tf"
}

variable "is_nodegroup_role_enabled" {
  description = "Enable or disable nodegroup IAM role"
  type        = bool
  default     = true
}

variable "pub_availability_zone" {
  type = list(string)
}

variable "pub_sub_name" {}

variable "pri_subnet_count" {}

variable "pri_cidr_block" {
  type = list(string)
}

variable "pri_availability_zone" {
  type = list(string)
}

variable "pri_sub_name" {}

variable "public_rt_name" {}

variable "private_rt_name" {}

variable "eip_name" {}

variable "ngw_name" {}

variable "eks_sg" {}

variable "is_eks_role_enabled" {
  type = bool
}

variable "is_eks_nodegroup_role_enabled" {
  type = bool
}

variable "is_eks_cluster_enabled" {
  type = bool
}

variable "cluster_version" {}

variable "endpoint_private_access" {}

variable "endpoint_public_access" {}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}

variable "ondemand_instance_types" {
  type = list(string)
}

variable "spot_instance_types" {
  type = list(string)
}

variable "desired_capacity_on_demand" {}

variable "min_capacity_on_demand" {}

variable "max_capacity_on_demand" {}

variable "desired_capacity_spot" {}

variable "min_capacity_spot" {}

variable "max_capacity_spot" {}