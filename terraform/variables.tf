variable "namespace" {
  type        = string
  description = "The name of project"
}

variable "db_password" {
  type        = string
  description = "The password for PostgreSQL instance in AWS RDS"
}

variable "db_user" {
  type        = string
  description = "The username for PostgreSQL instance in AWS RDS"
}
