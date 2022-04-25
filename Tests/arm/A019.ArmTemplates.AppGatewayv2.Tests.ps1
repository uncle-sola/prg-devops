
Describe "App Gateway Deployment Tests" -Tag "Acceptance" {

  BeforeAll{
# common variables
$ResourceGroupName = "prg-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\app-gateway-v2.json"
  }
  
  Context "When an app gateway is deployed with just a single pool" {
    BeforeAll{
      $TemplateParameters = @{
        appGatewayName      = "prg-foo-bar-ag"
        subnetRef           = "/subscriptions/f3b14109-a3de-4f54-9f58-46d891380a7e/resourceGroups/prg-foo-bar-rg/providers/Microsoft.Network/virtualNetworks/prg-foo-bar-vnet/subnets/appgateway"
        backendPools        = @( @{
                                    name = "mypool"
                                    fqdn = "foo.example.net"
                              } )
        backendHttpSettings = @( @{
                                    name                       = "myHttpSettings"
                                    port                       = 80
                                    protocol                   = "Http"
                                    hostnameFromBackendAddress = $true
                              } )
        routingRules        = @( @{ #routing rules dont make sense with only one backend but the template does not allow an empty routingrules array due to ARM template limitations
                                    name        = "myroutingrule"
                                    backendPool = "mypool"
                                    backendHttp = "myHttpSettings"
                                    paths       = @( "/dummy/*" )
                              } )
        publicIpAddressId   = "1.2.3.4"
        userAssignedIdentityName = "prg-test-template-uim"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
  
  
    }
  
    It "Should be deployed successfully" {
      $output = Test-AzResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

    if ($output) {
      Write-Error $output.Message
    }

  }
}