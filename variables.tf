variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
  default     = "wordpressadmin"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "wordpress_db"
}

variable "key_pair_name" {
  description = "The name of the EC2 key pair"
  type        = string
}

variable "my_ip" {
  description = "Your local IP address for SSH access"
  type        = string
}