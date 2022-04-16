Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Copy-SitefinityDatabase unit tests" -Tag "Unit" {
        
  
    Context "When the Azure resources do not exist" {

        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function Get-AzResource { 
                [CmdletBinding()]
                param($Name, $ResourceType)
            }

            function Get-AzWebApp {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
            }

            function Get-AzSqlDatabase {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName)
            }

            function New-AzSqlDatabaseCopy {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
            }

            # mock Get-AzResource: return valid object for prg-foo-sql and prg-foo-as, return null if not one of these
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-sql' } -MockWith { return @{
                    Name              = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Sql/servers'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql'
                } }
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-as' } -MockWith { return @{
                    Name              = 'prg-foo-as'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Web/sites'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                } }
            Mock Get-AzResource -MockWith { return $null }

            # mocks either overwritten in tests or that does not return anything
            Mock Get-AzWebApp -MockWith { return $null }
            Mock Get-AzSqlDatabase -MockWith { return $null }
            Mock New-AzSqlDatabaseCopy


        }

        BeforeEach {
            Mock Get-AzWebApp -MockWith { return @{
                    Name          = 'prg-foo-as'
                    Kind          = 'app'
                    ResourceGroup = 'prg-foo-rg'
                    Type          = 'Microsoft.Web/sites'
                    Id            = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                    SiteConfig    = @{ AppSettings = @(
                            @{ Name = 'DatabaseVersion'; Value = 'prg-foo-sitefinitydb' }
                        ) 
                    }
                } }

        }

        It "should throw an exception if SQL server does not exist" {
            { 
                ./Copy-SitefinityDatabase -ServerName not-a-sql-server -AppServiceName prg-foo-as  -ReleaseNumber 123
            } | Should -Throw "Could not find SQL server not-a-sql-server"
        }

        It "should throw an exception if app service does not exist" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName not-an-app-service -ServerName prg-foo-sql -ReleaseNumber 123
            } | Should -Throw "Could not find app service not-an-app-service"
        }

        It "should throw an exception if it cannot get the release number" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql
            } | Should -Throw "Cannot find environment variable RELEASE_RELEASENAME and no ReleaseNumber passed in"
        }

        It "should throw an exception if the current database does not exist" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql -ReleaseNumber 123
            } | Should -Throw "Could not find the current database prg-foo-sitefinitydb"
        }
    }

    Context "When not specifying the release number and the environment variable is set" {


        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function Get-AzResource { 
                [CmdletBinding()]
                param($Name, $ResourceType)
            }

            function Get-AzWebApp {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
            }

            function Get-AzSqlDatabase {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName)
            }

            function New-AzSqlDatabaseCopy {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
            }

            # mock Get-AzResource: return valid object for prg-foo-sql and prg-foo-as, return null if not one of these
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-sql' } -MockWith { return @{
                    Name              = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Sql/servers'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql'
                } }
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-as' } -MockWith { return @{
                    Name              = 'prg-foo-as'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Web/sites'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                } }
            Mock Get-AzResource -MockWith { return $null }

            # mocks either overwritten in tests or that does not return anything
            Mock Get-AzWebApp -MockWith { return $null }
            Mock Get-AzSqlDatabase -MockWith { return $null }
            Mock New-AzSqlDatabaseCopy


        }

        BeforeEach {
            Mock Get-AzWebApp -MockWith { return @{
                    Name          = 'prg-foo-as'
                    Kind          = 'app'
                    ResourceGroup = 'prg-foo-rg'
                    Type          = 'Microsoft.Web/sites'
                    Id            = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                    SiteConfig    = @{ AppSettings = @(
                            @{ Name = 'DatabaseVersion'; Value = 'prg-foo-sitefinitydb' }
                        ) 
                    }
                } }

            Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "prg-foo-sitefinitydb" } -MockWith { return @{
                    DatabaseName      = 'prg-foo-sitefinitydb'
                    ServerName        = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql/databases/prg-foo-sitefinitydb'
                    SkuName           = 'Standard'
                    ElasticPoolName   = $null
                } }

            Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "prg-foo-sitefinitydb-r123" } -MockWith { return $null }

            $env:RELEASE_RELEASENAME = "199-2"

            ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql

            Remove-Item Env:\RELEASE_RELEASENAME
        }

        It "should get the sql server resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-sql" }
        }

        It "should get the web app resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-as" }
        }

        It "should get the web app details" {
            Should -Invoke -CommandName Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "prg-foo-as" -and `
                    $ResourceGroupName -eq "prg-foo-rg"
            }
        }

        It "should get the existing table" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb"
            }
        }

        It "should look for a copy database called prg-foo-sitefinitydb-r199" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r199"
            }
        }

        It "Should copy prg-foo-sitefinitydb to prg-foo-sitefinitydb-r199" {
            Should -Invoke -CommandName New-AzSqlDatabaseCopy -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb" -and `
                    $CopyDatabaseName -eq "prg-foo-sitefinitydb-r199" -and `
                    $ElasticPoolName -eq $null
            }
        }
    }

    Context "When the web app does not have a DatabaseVersion app setting" {


        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function Get-AzResource { 
                [CmdletBinding()]
                param($Name, $ResourceType)
            }

            function Get-AzWebApp {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
            }

            function Get-AzSqlDatabase {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName)
            }

            function New-AzSqlDatabaseCopy {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
            }

            # mock Get-AzResource: return valid object for prg-foo-sql and prg-foo-as, return null if not one of these
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-sql' } -MockWith { return @{
                    Name              = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Sql/servers'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql'
                } }
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-as' } -MockWith { return @{
                    Name              = 'prg-foo-as'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Web/sites'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                } }
            Mock Get-AzResource -MockWith { return $null }

            # mocks either overwritten in tests or that does not return anything
            Mock Get-AzWebApp -MockWith { return $null }
            Mock Get-AzSqlDatabase -MockWith { return $null }
            Mock New-AzSqlDatabaseCopy


        }


        It "should throw an exception" {
            Mock Get-AzWebApp -MockWith { return $null }

            { 
                ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql -ReleaseNumber 123
            } | Should -throw "Could not determine current database version from DatabaseVersion app setting"
        }

    }

    Context "Everything specified exactly and currently a standard (not elastic pool) database with no version number attached" {


        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function Get-AzResource { 
                [CmdletBinding()]
                param($Name, $ResourceType)
            }

            function Get-AzWebApp {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
            }

            function Get-AzSqlDatabase {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName)
            }

            function New-AzSqlDatabaseCopy {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
            }

            # mock Get-AzResource: return valid object for prg-foo-sql and prg-foo-as, return null if not one of these
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-sql' } -MockWith { return @{
                    Name              = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Sql/servers'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql'
                } }
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-as' } -MockWith { return @{
                    Name              = 'prg-foo-as'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Web/sites'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                } }
            Mock Get-AzResource -MockWith { return $null }

            # mocks either overwritten in tests or that does not return anything
            Mock Get-AzWebApp -MockWith { return $null }
            Mock Get-AzSqlDatabase -MockWith { return $null }
            Mock New-AzSqlDatabaseCopy


        }

        BeforeEach {

            Mock Get-AzWebApp -MockWith { return @{
                    Name          = 'prg-foo-as'
                    Kind          = 'app'
                    ResourceGroup = 'prg-foo-rg'
                    Type          = 'Microsoft.Web/sites'
                    Id            = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                    SiteConfig    = @{ AppSettings = @(
                            @{ Name = 'DatabaseVersion'; Value = 'prg-foo-sitefinitydb' }
                        ) 
                    }
                } }
    
            Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "prg-foo-sitefinitydb" } -MockWith { return @{
                    DatabaseName      = 'prg-foo-sitefinitydb'
                    ServerName        = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql/databases/prg-foo-sitefinitydb'
                    SkuName           = 'Standard'
                    ElasticPoolName   = $null
                } }

            Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "prg-foo-sitefinitydb-r123" } -MockWith { return $null }

            ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql -ReleaseNumber 123

        }
        It "should get the sql server resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-sql" }
        }

        It "should get the web app resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-as" }
        }

        It "should get the web app details" {
            Should -Invoke -CommandName Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "prg-foo-as" -and `
                    $ResourceGroupName -eq "prg-foo-rg"
            }
        }
        
        It "should get the existing table" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb"
            }
        }

        It "should look for a copy database called prg-foo-sitefinitydb-r123" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r123"
            }
        }

        It "Should copy prg-foo-sitefinitydb to prg-foo-sitefinitydb-r123" {
            Should -Invoke -CommandName New-AzSqlDatabaseCopy -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb" -and `
                    $CopyDatabaseName -eq "prg-foo-sitefinitydb-r123" -and `
                    $ElasticPoolName -eq $null
            }
        }

    }

    Context "FQDN SQL server name passed and currently an elastic pool database with version number" {


        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function Get-AzResource { 
                [CmdletBinding()]
                param($Name, $ResourceType)
            }

            function Get-AzWebApp {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
            }

            function Get-AzSqlDatabase {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName)
            }

            function New-AzSqlDatabaseCopy {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
            }

            # mock Get-AzResource: return valid object for prg-foo-sql and prg-foo-as, return null if not one of these
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-sql' } -MockWith { return @{
                    Name              = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Sql/servers'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql'
                } }
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-as' } -MockWith { return @{
                    Name              = 'prg-foo-as'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Web/sites'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                } }
            Mock Get-AzResource -MockWith { return $null }

            # mocks either overwritten in tests or that does not return anything
            Mock Get-AzWebApp -MockWith { return $null }
            Mock Get-AzSqlDatabase -MockWith { return $null }
            Mock New-AzSqlDatabaseCopy


        }

        BeforeEach {
            Mock Get-AzWebApp -MockWith { return @{
                    Name          = 'prg-foo-as'
                    Kind          = 'app'
                    ResourceGroup = 'prg-foo-rg'
                    Type          = 'Microsoft.Web/sites'
                    Id            = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                    SiteConfig    = @{ AppSettings = @(
                            @{ Name = 'DatabaseVersion'; Value = 'prg-foo-sitefinitydb-r100' }
                        ) 
                    }
                } }
    
            Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "prg-foo-sitefinitydb-r100" } -MockWith { return @{
                    DatabaseName      = 'prg-foo-sitefinitydb'
                    ServerName        = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql/databases/prg-foo-sitefinitydb-r100'
                    SkuName           = 'ElasticPool'
                    ElasticPoolName   = 'prg-foo-epl'
                } }

            Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "prg-foo-sitefinitydb-r124" } -MockWith { return $null }

            ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql.database.windows.net -ReleaseNumber 124

        }

        It "should get the sql server resource description using name only" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-sql" }
        }

        It "should get the web app resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-as" }
        }

        It "should get the web app details" {
            Should -Invoke -CommandName Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "prg-foo-as" -and `
                    $ResourceGroupName -eq "prg-foo-rg"
            }
        }
        
        It "should get the existing table" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r100"
            }
        }

        It "should look for a copy database called prg-foo-sitefinitydb-r124" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r124"
            }
        }

        It "Should copy prg-foo-sitefinitydb to prg-foo-sitefinitydb-r124 in elastic pool" {
            Should -Invoke -CommandName New-AzSqlDatabaseCopy -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r100" -and `
                    $CopyDatabaseName -eq "prg-foo-sitefinitydb-r124" -and `
                    $ElasticPoolName -eq "prg-foo-epl"
            }
        }

    }

    Context "When the copy already exists" {


        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function Get-AzResource { 
                [CmdletBinding()]
                param($Name, $ResourceType)
            }

            function Get-AzWebApp {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
            }

            function Get-AzSqlDatabase {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName)
            }

            function New-AzSqlDatabaseCopy {
                [CmdletBinding()]
                param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
            }

            # mock Get-AzResource: return valid object for prg-foo-sql and prg-foo-as, return null if not one of these
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-sql' } -MockWith { return @{
                    Name              = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Sql/servers'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql'
                } }
            Mock Get-AzResource -ParameterFilter { $Name -eq 'prg-foo-as' } -MockWith { return @{
                    Name              = 'prg-foo-as'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceType      = 'Microsoft.Web/sites'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                } }
            Mock Get-AzResource -MockWith { return $null }

            # mocks either overwritten in tests or that does not return anything
            Mock Get-AzWebApp -MockWith { return $null }
            Mock Get-AzSqlDatabase -MockWith { return $null }
            Mock New-AzSqlDatabaseCopy


        }

        BeforeEach {

            Mock Get-AzWebApp -MockWith { return @{
                    Name          = 'prg-foo-as'
                    Kind          = 'app'
                    ResourceGroup = 'prg-foo-rg'
                    Type          = 'Microsoft.Web/sites'
                    Id            = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providersMicrosoft.Web/sites/prg-foo-as'
                    SiteConfig    = @{ AppSettings = @(
                            @{ Name = 'DatabaseVersion'; Value = 'prg-foo-sitefinitydb-r101' }
                        ) 
                    }
                } }
    
            Mock Get-AzSqlDatabase -MockWith { return @{
                    DatabaseName      = 'prg-foo-sitefinitydb-r1xx'
                    ServerName        = 'prg-foo-sql'
                    ResourceGroupName = 'prg-foo-rg'
                    ResourceId        = '/subscriptions/mock-sub/resourceGroups/prg-foo-rg/providers/Microsoft.Sql/servers/prg-foo-sql/databases/prg-foo-sitefinitydb-r1xx'
                    SkuName           = 'Standard'
                } }

            ./Copy-SitefinityDatabase -AppServiceName prg-foo-as -ServerName prg-foo-sql -ReleaseNumber 125

        }

        It "should get the sql server resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-sql" }
        }

        It "should get the web app resource description" {
            Should -Invoke -CommandName Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "prg-foo-as" }
        }

        It "should get the web app details" {
            Should -Invoke -CommandName Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "prg-foo-as" -and `
                    $ResourceGroupName -eq "prg-foo-rg"
            }
        }
        
        It "should get the existing table" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r101"
            }
        }

        It "should look for a copy database called prg-foo-sitefinitydb-r125" {
            Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "prg-foo-rg" -and `
                    $ServerName -eq "prg-foo-sql" -and `
                    $DatabaseName -eq "prg-foo-sitefinitydb-r125"
            }
        }

        It "Should not copy the database" {
            Should -Invoke -CommandName New-AzSqlDatabaseCopy -Exactly 0
        }

    }

}

Push-Location -Path $PSScriptRoot