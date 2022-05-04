Describe "Event Grid Subscription Tests" -Tag "Acceptance" {

  BeforeAll {

    # common variables
    $ResourceGroupName = "prg-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\eventgrid-subscription.json"

  }
  Context "When an Event Grid Subscription is deployed" {

    BeforeAll {

      $TemplateParameters = @{
        eventgridTopicName        = "prg-foo-bar-egt"
        eventgridSubscriptionName = "prg-foo-bar-egs"
        eventGridSubscriptionUrl  = "https://foo.bar"
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