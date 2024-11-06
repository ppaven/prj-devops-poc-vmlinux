
################
# Variables for naming convention

#---------
# Compagny trigram
variable "company_trig" {
  default = "AZCC"
}
#---------
# Environment
variable "env" {
  default = "POC"
}

#---------
# Short Service/Project name 
variable "service_name" {
  type    = string
  default = "VML"
}

################
# Location
variable "location" {
  default = "northeurope"
}

################
# Tags
variable tags {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}
