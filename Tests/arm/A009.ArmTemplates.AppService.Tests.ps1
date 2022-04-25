
Describe "App Service Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "prg-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\app-service.json"

  }
  
  Context "When app service is deployed with just name and ASP" {

    BeforeAll {
      $TemplateParameters = @{
        appServiceName     = "prg-foo-bar-as"
        appServicePlanName = "prg-test-template-asp"
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

  }

  Context "When app service is deployed as a function app" {

    BeforeAll {
      $TemplateParameters = @{
        appServiceName     = "prg-foo-bar-fa"
        appServicePlanName = "prg-test-template-asp"
        appServiceType     = "functionapp"
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

  }

}