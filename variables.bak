# Define resource group location
variable "resource_group_location" {
  type        = string
  default     = "australiaeast"
  description = "Location of the resource group."
}

# Define resource group name prefix
variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

# Define the username will be create the new VM
variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "azureadmin"
}

# Define the source SOE image id
variable "source_image_id" {
  type        = string
  description = "The source image id to build linux VM"
}

# Define application gateway backend address pool name
variable "backend_address_pool_name" {
  default = "jiraBackendPool"
}

# Define application gateway frontend port name
variable "frontend_port_name" {
  default = "jiraFrontendPort"
}

# Define application gateway frontend ip configuration name
variable "frontend_ip_configuration_name" {
  default = "jiraAGIPConfig"
}

# Define HTTP setting name
variable "http_setting_name" {
  default = "jiraHTTPsetting"
}

# Define listener name
variable "listener_name" {
  default = "jiraListener"
}

# Define routing rule name
variable "request_routing_rule_name" {
  default = "jiraAGRoutingRule"
}

# Define storage deploy location
variable "deploy_location" {
  type        = string
  default     = "australiaeast"
  description = "The Azure Region in which all resources should be created."
}

# Define storage account user
variable "avd_users" {
  description = "AVD users"
  default = [
    "angelqyg1982@gmail.com",
    "cyrus1006@hotmail.com"
  ]
}

variable "aad_group_name" {
  type        = string
  default     = "AVDUsers"
  description = "Azure Active Directory Group for AVD users"
}
