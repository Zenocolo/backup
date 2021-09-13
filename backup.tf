# Recovery Vault
resource "azurerm_recovery_services_vault" "vault" {
  name                = "vault-${local.prefix}"
  location            = var.location
  resource_group_name = var.rg-name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm" "bak-vm-policy" {
  name                = "bak-vm-policy-${local.prefix}"
  resource_group_name = var.rg-name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}

resource "azurerm_backup_protected_vm" "vm-bak-assignment" {
  count               = var.vmcount
  resource_group_name = var.rg-name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = element(var.virtual_machine_ids, count.index)
  backup_policy_id    = azurerm_backup_policy_vm.bak-vm-policy.id
}
