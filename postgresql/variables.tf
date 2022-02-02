variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
variable "prefix" {
  type    = string
  default = "abiels"
}
variable "postrgesql" {
  type = map(object({
    name                    = string
    size                    = string
    databases               = list(string)
    backup                  = bool
    threat_detection_policy = bool
  }))
}


variable "allowed_ips" {
  type = map(string)
}
