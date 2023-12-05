# THIS MIGHT NOT BE NEEDED

resource "azurerm_storage_account" "this" {
  name                = "storageaccountname"
  resource_group_name =  var.resource_group_name
  location            =  var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "this" {
  name                  = "eventhub-capture"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}