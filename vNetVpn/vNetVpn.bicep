@description('vNet name')
param vNetName string

@description('Subnet 1 name')
param sub1Name string

@description('Subnet 2 name')
param sub2Name string

@description('IP address prefix for vNet')
param vNetPrefix string

@description('Subnet 1 prefix within vNet')
param sub1Prefix string

@description('Subnet 2 prefix within vNet')
param sub2Prefix string

@description('Route based (Dynamic Gateway) or Policy based (Static Gateway)')
@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpnType string

@description('Location of deployed resources')
param location string

@description('CIDR block for gateway subnet, subset of azureVNetAddressPrefix address space')
param gtwaySubPrefix string

@description('Arbitrary name for public IP resource used for the new azure gateway')
param gtwayPIPName string

@description('Arbitrary name for the new gateway')
param gtwayName string

@description('The Sku of the Gateway')
param gtwaySku string

var gatewaySubnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', vNetName, 'GatewaySubnet')

resource vNetName_resource 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vNetName
  location: resourceGroup().location
  tags: {
    displayName: 'sbk-hub'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetPrefix
      ]
    }
    subnets: [
      {
        name: sub1Name
        properties: {
          addressPrefix: sub1Prefix
        }
      }
      {
        name: sub2Name
        properties: {
          addressPrefix: sub2Prefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gtwaySubPrefix
        }
      }
    ]
  }
  dependsOn: []
}

resource gtwayPIPName_resource 'Microsoft.Network/publicIPAddresses@2018-07-01' = {
  name: gtwayPIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource gtwayName_resource 'Microsoft.Network/virtualNetworkGateways@2018-07-01' = {
  name: gtwayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: gatewaySubnetRef
          }
          publicIPAddress: {
            id: gtwayPIPName_resource.id
          }
        }
        name: 'vnetGatewayConfig'
      }
    ]
    sku: {
      name: gtwaySku
      tier: gtwaySku
    }
    gatewayType: 'Vpn'
    vpnType: vpnType
    enableBgp: null
  }
  dependsOn: [
    vNetName_resource
  ]
}
