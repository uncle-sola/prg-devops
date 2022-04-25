
Describe "Redis Cache Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "prg-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\redis.json"
  }
  
  Context "When a Redis Cache is deployed with just a name" {

    BeforeAll {
      $TemplateParameters = @{
        redisName = "prg-foo-bar-rds"
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