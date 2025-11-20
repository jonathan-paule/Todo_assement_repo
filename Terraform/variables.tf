variable "ami_id" {
    description = "AMI id for your instance"
    type = string
    default = "ami-0c02fb55956c7d316"
}
variable "instance_type" {
    description = "ec2 instance type"
    type = string
    default = "t2.micro"
  
}

variable "key_name" {
    description = "key name"
    type = string
    default = "todo_key_pair"
  
}
variable "project" {
    description = "project name"
    type = string
    default = "Todo_api"

  
}

variable "function_name" {
    description = "lambda_fun_name"
    type = string
    default = "todo-crud"
}
variable "runtime" {
    description = "lambda runtime" 
    type = string
    default = "python3.12"
  
}

variable "filename" {
    description = "file name for lambda" 
    type = string
    default = "lambda/todo-api.zip"
  
}
variable "engine" {
    description = "RDS engine" 
    type = string
    default = "mysql"
  
}

variable "instance_class" {
    description = "instance class for RDS" 
    type = string
    default = "db.t3.micro"
  
}

variable "api_name" {
    description = "api_name" 
    type = string
    default = "todo-http-api"
  
}

variable "protocol_type" {
    description = " protocal_type"
    type = string
    default = "HTTP"
  
}

variable "my_ip" {
    description = "my_ip"
    type = string
    default = "49.205.34.24/32"
  
}

variable "region" {
    description = "region"
    type = string
    default = "us-east-1"
  
}


variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true

}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  sensitive   = true
}


