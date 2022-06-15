variable "aws_region" {
  description = "The AWS region where to deploy application."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(object({
      name = string
      az   = string
      cidr = string
  }))

  description = "List of the public subnets to be created in their respective AZ."

  default = [
    {
      name = "alb-subnet"
      az   = "us-east-1a"
      cidr = "10.0.0.0/24"
    },
    {
      name = "alb-subnet"
      az   = "us-east-1b"
      cidr = "10.0.1.0/24"
    }
  ]
}

variable "private_subnets" {
  type        = list(object({
      name = string
      az   = string
      cidr = string
  }))

  description = "List of the private subnets to be created in their respective AZ."

  default = [
    {
      name = "subnet-1a"
      az   = "us-east-1a"
      cidr = "10.0.2.0/24"
    },
    {
      name = "subnet-1b"
      az   = "us-east-1b"
      cidr = "10.0.3.0/24"
    }
  ]
}
