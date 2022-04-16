Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Unpublish-AzureRmCdnEndpointContent {}

Describe "Clear-Cdn unit tests" -Tag "Unit" {


    It "Should pass parameters to Unpublish-AzureRmCdnEndpointContent" {

        Mock Unpublish-AzureRmCdnEndpointContent

        .\Clear-Cdn -ResourceGroupName prg-foo-bar-rg -CdnName prg-foo-bar-cdn -EndpointName prg-foo-bar-assets

        Should -Invoke -CommandName Unpublish-AzureRmCdnEndpointContent

    }

}

Push-Location -Path $PSScriptRoot