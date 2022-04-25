
Describe "Service Bus Topic Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "prg-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\ServiceBus\servicebus-topic.json"
  }
  
  Context "When deploying the Service Bus Topic" {

    BeforeAll {
      $TemplateParameters = @{
        serviceBusNamespaceName = "prg-foo-bar-ns"
        serviceBusTopicName     = "topic-name"
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