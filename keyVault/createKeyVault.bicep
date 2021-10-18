@description('Name of Key Vault. Code makes key vault into a unique string. So defaultValue concatenates kv- plus generates a unique name from the Resource Group name.')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

@description('Sku for Key Vault. Choose either the Standard or Premium SKU.')
@allowed([
  'Standard'
  'Premium'
])
param keyVaultSku string

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
@allowed([
  true
  false
])
param enabledForDeployment bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
@allowed([
  true
  false
])
param enabledForTemplateDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
@allowed([
  true
  false
])
param enabledForDiskEncryption bool = false

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keyPermissions array

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretPermissions array

@description('Specifies the permissions to certificates in the vault. Valid values are: all, get, list, set, delete, recover, backup, restore, purge')
param certificatePermissions array

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string

@description('Specifies the object ID of a user, service principal, or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: 'eastus'
  properties: {
    sku: {
      family: 'A'
      name: keyVaultSku
    }
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          keys: keyPermissions
          secrets: secretPermissions
          certificates: certificatePermissions
        }
      }
    ]
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
  }
}
