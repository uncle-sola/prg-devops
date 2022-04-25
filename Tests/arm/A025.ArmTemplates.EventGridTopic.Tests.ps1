
Describe "Event Grid Topic Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "prg-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\eventgrid-topic.json"
  }

  Context "When an Event Grid Topic is deployed with a name and sku" {

    BeforeAll {
      $TemplateParameters = @{
        eventgridTopicName = "prg-foo-bar-egt"
        eventgridTopicSku  = "basic"
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