# https://registry.terraform.io/modules/Azure/avm-ptn-policyassignment/azurerm/latest

resource "azurerm_management_group" "root" {
  name = "test-mg"
}

module "avm-ptn-policyassignment" {
  source           = "Azure/avm-ptn-policyassignment/azurerm"
  version          = "0.2.0"
  enable_telemetry = var.enable_telemetry

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = azurerm_management_group.root.id
  name                 = "Enforce-GR-Keyvault"
  display_name         = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  description          = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  enforce              = "Default"
  location             = module.regions.regions[random_integer.region_index.result].name
  identity             = { "type" = "SystemAssigned" }

  role_assignments = {
    storage = {
      "role_definition_id_or_name" : "/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe", # Storage Blob Data Contributor
      principal_id : "ignored"
    },
    contrib = {
      "role_definition_id_or_name" : "Contributor"
      principal_id : "ignored"
    }
  }

  parameters = {
    maximumDaysToRotate = {
      value = 90
    }
  }
}
