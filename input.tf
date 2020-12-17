variable "allowed_ssh" {
  type = set(string)
  description = "SSH CIDR sets from which you'll be connecting"
}
variable "key_name" {
  type = string
  description = "SSH key to allow. Must already exist in aws, use 'aws ec2 create-key-pair --key-name tfexample --output text' to create"
}
variable "name_tag" {
  type = string
  description = "Name to put in the Name tag, so resources can be easier identified when using AWS Console"
}