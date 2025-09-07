variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}
