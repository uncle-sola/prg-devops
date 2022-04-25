
Describe "Sql Database Deployment Tests" -Tag "Acceptance" {
    BeforeAll {
        # common variables
        $ResourceGroupName = "prg-test-template-rg"
        $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\SqlServer\sql-database.json"
        $TemplateParametersDefault = @{
            databaseName  = "prg-foo-bar-db"
            sqlServerName = "prg-foo-bar-sql"
        }
    }
        
    Context "When SQL Database is deployed with databaseName, sqlServerName" {

        BeforeAll {
            $TemplateParameters = $TemplateParametersDefault
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

    Context "When SQL Database is deployed with databaseName, sqlServerName and databaseTier of Basic" {

        BeforeAll {
            $TemplateParameters = $TemplateParametersDefault
            $TemplateParameters['databaseTier'] = "Basic"
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

    Context "When SQL Database is deployed with databaseName, sqlServerName and databaseTier of Standard and a databaseSize of 2" {

        BeforeAll {
            $TemplateParameters = $TemplateParametersDefault
            $TemplateParameters['databaseTier'] = "Standard"
            $TemplateParameters['databaseSize'] = "2"
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