#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'Catesta'
#-------------------------------------------------------------------------
#if the module is already in memory, remove it
Get-Module $ModuleName | Remove-Module -Force
$PathToManifest = [System.IO.Path]::Combine('..', '..', '..', $ModuleName, "$ModuleName.psd1")
#-------------------------------------------------------------------------
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
$WarningPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
#-------------------------------------------------------------------------
InModuleScope $ModuleName {
    $functionName = 'New-VaultProject'
    Describe "$functionName Function Tests" -Tag Unit {
        Mock -CommandName Write-Error { }
        Mock -CommandName Write-Warning { }
        Context 'ShouldProcess' {
            Mock -CommandName Invoke-Plaster { }
            Mock -CommandName Import-Module { }
            Mock -CommandName New-VaultProject -MockWith { } #endMock
            It 'Should process by default' {
                New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path
                Assert-MockCalled New-VaultProject -Scope It -Exactly -Times 1
            } #it
            It 'Should not process on explicit request for confirmation (-Confirm)' {
                { New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path -Confirm }
                Assert-MockCalled New-VaultProject -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
                {
                    $ConfirmPreference = 'Low'
                    New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path
                }
                Assert-MockCalled New-VaultProject -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on explicit request for validation (-WhatIf)' {
                { New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path -WhatIf }
                Assert-MockCalled New-VaultProject -Scope It -Exactly -Times 0
            } #it
            It 'Should not process on implicit request for validation (WhatIfPreference)' {
                {
                    $WhatIfPreference = $true
                    New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path
                }
                Assert-MockCalled New-VaultProject -Scope It -Exactly -Times 0
            } #it
            It 'Should process on force' {
                $ConfirmPreference = 'Medium'
                New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path -Force
                Assert-MockCalled New-VaultProject -Scope It -Exactly -Times 1
            } #it
        }
        BeforeEach {
            Mock -CommandName Import-Module { }
            Mock -CommandName Invoke-Plaster -MockWith {
                [PSCustomObject]@{
                    TemplatePath    = 'C:\Users\jakew\Desktop\Project\0_CodeProject\Catesta\src\Catesta\Resources\AWS'
                    DestinationPath = 'C:\rs-pkgs\test\plastertest3'
                    Success         = $true
                    TemplateType    = 'Project'
                    CreatedFiles    = '{C:\rs-pkgs\test\plastertest3\.vscode\tasks.json}'
                    UpdatedFiles    = '{}'
                    MissingModules  = '{}'
                    OpenFiles       = '{C:\rs-pkgs\test\plastertest3\src\test12234\test12234.psd1, C:\rs-pkgs\test\plastertest3\src\test12234\test12234.psm1}'
                }
            } #endMock
        } #beforeEach
        Context 'Error' {
            It 'should return success status false if Plaster module can not be imported' {
                Mock -CommandName Import-Module -MockWith {
                    throw 'Fake Error'
                } #endMock
                { New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path } | Should throw
            } #it
            It 'should return success status false if an error is encountered' {
                Mock -CommandName Invoke-Plaster -MockWith {
                    throw 'Fake Error'
                }
                (New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path).Success | Should -BeExactly $false
            } #it
        } #context_Error
        Context 'Success' {
            It 'should return success status true if no issues are encountered' {
                (New-VaultProject -CICDChoice 'AWS' -DestinationPath c:\path\AWSProject).Success | Should -BeExactly $true
                (New-VaultProject -CICDChoice 'GitHubActions' -DestinationPath c:\path\GitHubActions).Success | Should -BeExactly $true
                (New-VaultProject -CICDChoice 'Azure' -DestinationPath c:\path\AzurePipeline).Success | Should -BeExactly $true
                (New-VaultProject -CICDChoice 'AppVeyor' -DestinationPath c:\path\AppVeyor).Success | Should -BeExactly $true
                (New-VaultProject -CICDChoice 'ModuleOnly' -DestinationPath c:\path\ModuleOnly).Success | Should -BeExactly $true
            } #it
        } #context_Success
    } #describe
} #inModule
