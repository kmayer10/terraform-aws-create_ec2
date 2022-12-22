variable "instance_type" {}
variable "key_name" {}
variable "client" {
  default = "thinknyx"
}
variable "project" {
  default = "internal"
}
variable "ingress" {
  default = [
    {
      self = true
      description = "all open"
    },
    {
      from_port = 22
      to_port = 22
      description = "SSH"
      cidr_blocks = ["0.0.0.0/0"]
      protocol = "TCP"
    }
  ]
}
variable "root_volume_size" {
  default = "10"
}
variable "data_volume_needed" {
  default = false
}
variable "data_volume_size" {
  default = "0"
}
