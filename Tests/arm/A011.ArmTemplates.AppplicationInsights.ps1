
Describe "App Service Plan Deployment Tests" -Tag "Acceptance" {

  BeforeAll{
# common variables
$ResourceGroupName = "prg-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\application-insights.json"
  }
  
  Context "When application insights is deployed with just name" {

    BeforeAll{
      $TemplateParameters = @{
        appInsightsName = "prg-foo-bar-ai"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
      }
  
    It "Should be deployed successfully" {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

  }
}