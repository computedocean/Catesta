#-------------------------------------------------------------------------
Set-Location -Path $PSScriptRoot
#-------------------------------------------------------------------------
$ModuleName = 'Catesta'
#-------------------------------------------------------------------------
#if the module is already in memory, remove it
Get-Module $ModuleName | Remove-Module -Force
$PathToManifest = [System.IO.Path]::Combine('..', '..', 'Artifacts', "$ModuleName.psd1")
#-------------------------------------------------------------------------
Import-Module $PathToManifest -Force
#-------------------------------------------------------------------------
$resourcePath1 = [System.IO.Path]::Combine( '..', '..', $ModuleName, 'Resources')
# $manifests = Get-ChildItem -Path $resourcePath1 -Include '*.xml' -Recurse -Force
#-------------------------------------------------------------------------
Describe 'Vault Infra Tests' {

    BeforeAll {
        $WarningPreference = 'Continue'
        Set-Location -Path $PSScriptRoot
        $ModuleName = 'Catesta'
        # $resourcePath = [System.IO.Path]::Combine( '..', '..', $ModuleName, 'Resources')
        # $PathToManifest = [System.IO.Path]::Combine('..', '..', $ModuleName, "$ModuleName.psd1")
        # $srcRoot = [System.IO.Path]::Combine( '..', '..')
        $outPutPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), 'catesta_infra_testing')
        $outPutPathStar = "$outPutPath$([System.IO.Path]::DirectorySeparatorChar)*"
        $buildFile = [System.IO.Path]::Combine($outPutPath, 'src', 'SecretManagement.MyVault.build.ps1')
        New-Item -Path $outPutPath -ItemType Directory  -ErrorAction SilentlyContinue
    } #beforeAll

    Context 'Module Checks' {

        BeforeEach {
            Remove-Item -Path $outPutPathStar -Recurse -Force
            # $codeBuildModuleFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force
        } #beforeEach
        # BeforeAll {
        #     Remove-Item -Path $outPutPathStar -Recurse -Force
        # }

        Context 'CI/CD' {

            Context 'Vault Only' {

                It 'should generate a vault only scaffold with base elements' {
                    $vaultParameters = @{
                        VAULT       = 'text'
                        ModuleName  = 'SecretManagement.MyVault'
                        Description = 'text'
                        Version     = '0.0.1'
                        FN          = 'user full name'
                        CICD        = 'NONE'
                        RepoType    = 'NONE'
                        CodingStyle = 'Stroustrup'
                        Pester      = '5'
                        S3Bucket    = 'PSGallery'
                        PassThru    = $true
                        NoLogo      = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $moduleOnlyFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    $moduleOnlyFiles.Name.Contains('actions_bootstrap.ps1') | Should -BeExactly $false

                    # VAULT
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault.psd1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault.psm1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault.Extension.psd1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault.Extension.psm1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault.build.ps1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault.Settings.ps1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('PSScriptAnalyzerSettings.psd1') | Should -BeExactly $true

                    # Module - not present
                    $moduleOnlyFiles.Name.Contains('Get-HelloWorld.ps1') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('Get-Day.ps1') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('Imports.ps1') | Should -BeExactly $false

                    # Tests
                    $moduleOnlyFiles.Name.Contains('ExportedFunctions.Tests.ps1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault-Module.Tests.ps1') | Should -BeExactly $true
                    $moduleOnlyFiles.Name.Contains('SecretManagement.MyVault-Function.Tests.ps1') | Should -BeExactly $true

                    # LICENSE
                    $moduleOnlyFiles.Name.Contains('GNULICENSE') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('ISCLICENSE') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('MITLICENSE') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('APACHELICENSE') | Should -BeExactly $false

                    # REPO
                    $moduleOnlyFiles.Name.Contains('CHANGELOG.md') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('CODE_OF_CONDUCT.md') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('CONTRIBUTING.md') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('SECURITY.md') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('.gitignore') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('PULL_REQUEST_TEMPLATE.md') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('bug-report.md') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('feature_request.md') | Should -BeExactly $false

                    # AWS
                    $moduleOnlyFiles.Name.Contains('buildspec_powershell_windows.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('buildspec_pwsh_linux.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('buildspec_pwsh_windows.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('configure_aws_credential.ps1') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('install_modules.ps1') | Should -BeExactly $false

                    $moduleOnlyFiles.Name.Contains('PowerShellCodeBuildCC.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('PowerShellCodeBuildGit.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('S3BucketsForPowerShellDevelopment.yml') | Should -BeExactly $false

                    # GitHub
                    $moduleOnlyFiles.Name.Contains('wf_Linux.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('wf_MacOS.yml') | Should -BeExactly $false
                    $moduleOnlyFiles.Name.Contains('wf_Windows.yml') | Should -BeExactly $false

                    # Azure
                    $moduleOnlyFiles.Name.Contains('azure-pipelines.yml') | Should -BeExactly $false

                    # AppVeyor
                    $moduleOnlyFiles.Name.Contains('appveyor.yml') | Should -BeExactly $false

                    $buildContent = Get-Content -Path $buildFile -Raw

                    # Styling
                    $buildContent | Should -BeLike '*Stroustrup*'

                    # Pester
                    $buildContent | Should -BeLike '*5.2.2*'

                    # Help
                    $buildContent | Should -Not -BeLike '*CreateHelpStart*'

                } #it

            } #context_vault_only

            Context 'AWS-CodeBuild' {

                It 'should generate a CodeBuild based module stored on GitHub with all required elements' {
                    $vaultParameters = @{
                        VAULT       = 'text'
                        ModuleName  = 'SecretManagement.MyVault'
                        Description = 'text'
                        Version     = '0.0.1'
                        FN          = 'user full name'
                        CICD        = 'CODEBUILD'
                        AWSOptions  = 'ps', 'pwshcore', 'pwsh'
                        RepoType    = 'GITHUB'
                        License     = 'MIT'
                        Changelog   = 'CHANGELOG'
                        COC         = 'CONDUCT'
                        Contribute  = 'CONTRIBUTING'
                        Security    = 'SECURITY'
                        CodingStyle = 'Stroustrup'
                        Pester      = '5'
                        S3Bucket    = 'PSGallery'
                        PassThru    = $true
                        NoLogo      = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $codeBuildModuleFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    $codeBuildModuleFiles.Name.Contains('buildspec_powershell_windows.yml') | Should -BeExactly $true
                    $codeBuildModuleFiles.Name.Contains('buildspec_pwsh_linux.yml') | Should -BeExactly $true
                    $codeBuildModuleFiles.Name.Contains('buildspec_pwsh_windows.yml') | Should -BeExactly $true
                    $powershellContentPath = [System.IO.Path]::Combine($outPutPath, 'buildspec_powershell_windows.yml')
                    $powershellContent = Get-Content -Path $powershellContentPath -Raw
                    $powershellContent | Should -BeLike '*SecretManagement.MyVault*'
                    $linuxContentPath = [System.IO.Path]::Combine($outPutPath, 'buildspec_pwsh_linux.yml')
                    $linuxContent = Get-Content -Path $linuxContentPath -Raw
                    $linuxContent | Should -BeLike '*SecretManagement.MyVault*'
                    $pwshContentPath = [System.IO.Path]::Combine($outPutPath, 'buildspec_pwsh_windows.yml')
                    $pwshContent = Get-Content -Path $pwshContentPath -Raw
                    $pwshContent | Should -BeLike '*SecretManagement.MyVault*'

                    $codeBuildModuleFiles.Name.Contains('configure_aws_credential.ps1') | Should -BeExactly $true

                    $codeBuildModuleFiles.Name.Contains('install_modules.ps1') | Should -BeExactly $true
                    $installContentPath = [System.IO.Path]::Combine($outPutPath, 'install_modules.ps1')
                    $installContent = Get-Content -Path $installContentPath -Raw
                    $installContent | Should -BeLike '*$galleryDownload = $true*'
                    $installContent | Should -BeLike '*Microsoft.PowerShell.SecretManagement*'

                    $codeBuildModuleFiles.Name.Contains('PowerShellCodeBuildCC.yml') | Should -BeExactly $false
                    $codeBuildModuleFiles.Name.Contains('PowerShellCodeBuildGit.yml') | Should -BeExactly $true
                    $codeBuildModuleFiles.Name.Contains('S3BucketsForPowerShellDevelopment.yml') | Should -BeExactly $true

                    $cfnContentPath = [System.IO.Path]::Combine($outPutPath, 'CloudFormation', 'PowerShellCodeBuildGit.yml')
                    $cfnContent = Get-Content -Path $cfnContentPath -Raw
                    $cfnContent | Should -BeLike "*CodeBuildpsProject*"
                    $cfnContent | Should -BeLike "*CodeBuildpwshcoreProject*"
                    $cfnContent | Should -BeLike "*CodeBuildpwshProject*"
                } #it

                It 'should generate a CodeBuild based module stored on CodeCommit with all required elements' {
                    $vaultParameters = @{
                        VAULT       = 'text'
                        ModuleName  = 'SecretManagement.MyVault'
                        Description = 'text'
                        Version     = '0.0.1'
                        FN          = 'user full name'
                        CICD        = 'CODEBUILD'
                        AWSOptions  = 'ps', 'pwshcore', 'pwsh'
                        RepoType    = 'CodeCommit'
                        License     = 'MIT'
                        Changelog   = 'CHANGELOG'
                        COC         = 'CONDUCT'
                        Contribute  = 'CONTRIBUTING'
                        Security    = 'SECURITY'
                        CodingStyle = 'Stroustrup'
                        Pester      = '5'
                        S3Bucket    = 'PSGallery'
                        PassThru    = $true
                        NoLogo      = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $codeBuildModuleFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    $codeBuildModuleFiles.Name.Contains('buildspec_powershell_windows.yml') | Should -BeExactly $true
                    $codeBuildModuleFiles.Name.Contains('buildspec_pwsh_linux.yml') | Should -BeExactly $true
                    $codeBuildModuleFiles.Name.Contains('buildspec_pwsh_windows.yml') | Should -BeExactly $true

                    $codeBuildModuleFiles.Name.Contains('configure_aws_credential.ps1') | Should -BeExactly $true

                    $codeBuildModuleFiles.Name.Contains('install_modules.ps1') | Should -BeExactly $true
                    $installContentPath = [System.IO.Path]::Combine($outPutPath, 'install_modules.ps1')
                    $installContent = Get-Content -Path $installContentPath -Raw
                    $installContent | Should -BeLike '*$galleryDownload = $true*'
                    $installContent | Should -BeLike '*Microsoft.PowerShell.SecretManagement*'

                    $codeBuildModuleFiles.Name.Contains('PowerShellCodeBuildCC.yml') | Should -BeExactly $true
                    $codeBuildModuleFiles.Name.Contains('PowerShellCodeBuildGit.yml') | Should -BeExactly $false
                    $codeBuildModuleFiles.Name.Contains('S3BucketsForPowerShellDevelopment.yml') | Should -BeExactly $true

                    $cfnContentPath = [System.IO.Path]::Combine($outPutPath, 'CloudFormation', 'PowerShellCodeBuildCC.yml')
                    $cfnContent = Get-Content -Path $cfnContentPath -Raw
                    $cfnContent | Should -BeLike "*CodeBuildProjectWPS*"
                    $cfnContent | Should -BeLike "*CodeBuildProjectWPwsh*"
                    $cfnContent | Should -BeLike "*CodeBuildProjectLPwsh*"
                } #it

            } #aws_codeBuild

            Context 'Azure Pipelines' {

                It 'should generate an Azure Pipelines based module stored on GitHub with all required elements' {
                    $vaultParameters = @{
                        VAULT        = 'text'
                        ModuleName   = 'SecretManagement.MyVault'
                        Description  = 'text'
                        Version      = '0.0.1'
                        FN           = 'user full name'
                        CICD         = 'AZURE'
                        AzureOptions = 'windows', 'pwshcore', 'linux', 'macos'
                        RepoType     = 'GITHUB'
                        License      = 'None'
                        Changelog    = 'NOCHANGELOG'
                        COC          = 'NOCONDUCT'
                        Contribute   = 'NOCONTRIBUTING'
                        Security     = 'NOSECURITY'
                        CodingStyle  = 'Stroustrup'
                        Pester       = '5'
                        PassThru     = $true
                        NoLogo       = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $azureModuleFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    $azureModuleFiles.Name.Contains('azure-pipelines.yml') | Should -BeExactly $true
                    $azureModuleFiles.Name.Contains('actions_bootstrap.ps1') | Should -BeExactly $true

                    $installContentPath = [System.IO.Path]::Combine($outPutPath, 'actions_bootstrap.ps1')
                    $installContent = Get-Content -Path $installContentPath -Raw
                    $installContent | Should -BeLike '*Microsoft.PowerShell.SecretManagement*'

                    $azureYMLContentPath = [System.IO.Path]::Combine($outPutPath, 'azure-pipelines.yml')
                    $azureYMLContent = Get-Content -Path $azureYMLContentPath -Raw
                    $azureYMLContent | Should -BeLike "*build_ps_WinLatest*"
                    $azureYMLContent | Should -BeLike "*build_pwsh_WinLatest*"
                    $azureYMLContent | Should -BeLike "*build_pwsh_ubuntuLatest*"
                    $azureYMLContent | Should -BeLike "*build_pwsh_macOSLatest*"
                } #it

            } #azure_pipelines

            Context 'Appveyor Build' {

                It 'should generate an Appveyor based module stored on GitHub with all required elements' {
                    $vaultParameters = @{
                        VAULT           = 'text'
                        ModuleName      = 'SecretManagement.MyVault'
                        Description     = 'text'
                        Version         = '0.0.1'
                        FN              = 'user full name'
                        CICD            = 'APPVEYOR'
                        AppveyorOptions = 'windows', 'pwshcore', 'linux', 'macos'
                        RepoType        = 'GITHUB'
                        License         = 'None'
                        Changelog       = 'NOCHANGELOG'
                        COC             = 'NOCONDUCT'
                        Contribute      = 'NOCONTRIBUTING'
                        Security        = 'NOSECURITY'
                        CodingStyle     = 'Stroustrup'
                        Pester          = '5'
                        PassThru        = $true
                        NoLogo          = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $appveyorModuleFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    $appveyorModuleFiles.Name.Contains('appveyor.yml') | Should -BeExactly $true
                    $appveyorModuleFiles.Name.Contains('actions_bootstrap.ps1') | Should -BeExactly $true

                    $installContentPath = [System.IO.Path]::Combine($outPutPath, 'actions_bootstrap.ps1')
                    $installContent = Get-Content -Path $installContentPath -Raw
                    $installContent | Should -BeLike '*Microsoft.PowerShell.SecretManagement*'

                    $appveyorYMLContentPath = [System.IO.Path]::Combine($outPutPath, 'appveyor.yml')
                    $appveyorYMLContent = Get-Content -Path $appveyorYMLContentPath -Raw
                    $appveyorYMLContent | Should -BeLike "*Visual Studio 2019*"
                    $appveyorYMLContent | Should -BeLike "*Visual Studio 2022*"
                    $appveyorYMLContent | Should -BeLike "*Ubuntu2004*"
                    $appveyorYMLContent | Should -BeLike "*macOS*"
                } #it

            } #appveyor

            Context 'GitHub Actions' {

                It 'should generate a GitHub Actions based module stored on GitHub with all required elements' {
                    $vaultParameters = @{
                        VAULT          = 'text'
                        ModuleName     = 'SecretManagement.MyVault'
                        Description    = 'text'
                        Version        = '0.0.1'
                        FN             = 'user full name'
                        CICD           = 'GITHUB'
                        GitHubAOptions = 'windows', 'pwshcore', 'linux', 'macos'
                        RepoType       = 'GITHUB'
                        License        = 'None'
                        Changelog      = 'NOCHANGELOG'
                        COC            = 'NOCONDUCT'
                        Contribute     = 'NOCONTRIBUTING'
                        Security       = 'NOSECURITY'
                        CodingStyle    = 'Stroustrup'
                        Pester         = '5'
                        PassThru       = $true
                        NoLogo         = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $ghaModuleFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    $ghaModuleFiles.Name.Contains('wf_Linux.yml') | Should -BeExactly $true
                    $ghaModuleFiles.Name.Contains('wf_MacOS.yml') | Should -BeExactly $true
                    $ghaModuleFiles.Name.Contains('wf_Windows_Core.yml') | Should -BeExactly $true
                    $ghaModuleFiles.Name.Contains('wf_Windows.yml') | Should -BeExactly $true

                    $installContentPath = [System.IO.Path]::Combine($outPutPath, 'actions_bootstrap.ps1')
                    $installContent = Get-Content -Path $installContentPath -Raw
                    $installContent | Should -BeLike '*Microsoft.PowerShell.SecretManagement*'

                    $wfLinuxContentPath = [System.IO.Path]::Combine($outPutPath, '.github', 'workflows', 'wf_Linux.yml')
                    $wfLinuxContent = Get-Content -Path $wfLinuxContentPath -Raw
                    $wfLinuxContent | Should -BeLike "*SecretManagement.MyVault*"

                    $wfMacOSContentPath = [System.IO.Path]::Combine($outPutPath, '.github', 'workflows', 'wf_MacOS.yml')
                    $wfMacOSContent = Get-Content -Path $wfMacOSContentPath -Raw
                    $wfMacOSContent | Should -BeLike "*SecretManagement.MyVault*"

                    $wfWindowsCoreContentPath = [System.IO.Path]::Combine($outPutPath, '.github', 'workflows', 'wf_Windows_Core.yml')
                    $wfWindowsCoreContent = Get-Content -Path $wfWindowsCoreContentPath -Raw
                    $wfWindowsCoreContent | Should -BeLike "*SecretManagement.MyVault*"

                    $wfWindowsContentPath = [System.IO.Path]::Combine($outPutPath, '.github', 'workflows', 'wf_Windows.yml')
                    $wfWindowsContent = Get-Content -Path $wfWindowsContentPath -Raw
                    $wfWindowsContent | Should -BeLike "*SecretManagement.MyVault*"

                } #it

            } #github_actions

        } #context_cicd

        Context 'Repo Checks' {

            Context 'CodeCommit' {

                It 'should generate the appropriate repo files for CodeCommit' {
                    $vaultParameters = @{
                        VAULT       = 'text'
                        ModuleName  = 'SecretManagement.MyVault'
                        Description = 'text'
                        Version     = '0.0.1'
                        FN          = 'user full name'
                        CICD        = 'NONE'
                        RepoType    = 'CODECOMMIT'
                        License     = 'MIT'
                        Changelog   = 'CHANGELOG'
                        COC         = 'CONDUCT'
                        Contribute  = 'CONTRIBUTING'
                        Security    = 'SECURITY'
                        CodingStyle = 'Stroustrup'
                        Pester      = '5'
                        S3Bucket    = 'PSGallery'
                        PassThru    = $true
                        NoLogo      = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $repoFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    # REPO
                    $repoFiles.Name.Contains('.gitignore') | Should -BeExactly $true

                    $repoFiles.Name.Contains('PULL_REQUEST_TEMPLATE.md') | Should -BeExactly $false
                    $repoFiles.Name.Contains('bug-report.md') | Should -BeExactly $false
                    $repoFiles.Name.Contains('feature_request.md') | Should -BeExactly $false

                    $rootRepoFiles = Get-ChildItem -Path $outPutPath
                    $rootRepoFiles.Name.Contains('CODE_OF_CONDUCT.md') | Should -BeExactly $true
                    $rootRepoFiles.Name.Contains('CONTRIBUTING.md') | Should -BeExactly $true
                    $rootRepoFiles.Name.Contains('SECURITY.md') | Should -BeExactly $true

                    $docFiles = @(
                        'CHANGELOG.md'
                    )
                    foreach ($file in $dotGitHubFiles) {
                        ($repoFiles | Where-Object { $_.name -eq $file }).Directory | Should -BeLike '*.github*'
                    }
                    foreach ($file in $docFiles) {
                        ($repoFiles | Where-Object { $_.name -eq $file }).Directory | Should -BeLike '*docs*'
                    }

                } #it

            } #context_codecommit

            Context 'GitHub' {

                It 'should generate the appropriate repo files for GitHub' {
                    $vaultParameters = @{
                        VAULT       = 'text'
                        ModuleName  = 'SecretManagement.MyVault'
                        Description = 'text'
                        Version     = '0.0.1'
                        FN          = 'user full name'
                        CICD        = 'NONE'
                        RepoType    = 'GITHUB'
                        License     = 'MIT'
                        Changelog   = 'CHANGELOG'
                        COC         = 'CONDUCT'
                        Contribute  = 'CONTRIBUTING'
                        Security    = 'SECURITY'
                        CodingStyle = 'Stroustrup'
                        Pester      = '5'
                        S3Bucket    = 'PSGallery'
                        PassThru    = $true
                        NoLogo      = $true
                    }
                    $eval = New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath
                    $eval | Should -Not -BeNullOrEmpty

                    $repoFiles = Get-ChildItem -Path $outPutPathStar -Recurse -Force

                    # LICENSE
                    $repoFiles.Name.Contains('LICENSE') | Should -BeExactly $true
                    $licenseContentPath = [System.IO.Path]::Combine($outPutPath, 'LICENSE')
                    $licenseContent = Get-Content -Path $licenseContentPath -Raw
                    $licenseContent | Should -BeLike '*mit*'

                    # REPO
                    $repoFiles.Name.Contains('CHANGELOG.md') | Should -BeExactly $true
                    $changelogContentPath = [System.IO.Path]::Combine($outPutPath, 'docs', 'CHANGELOG.md')
                    $changelogContent = Get-Content -Path $changelogContentPath -Raw
                    $changelogContent | Should -BeLike '*0.0.1*'
                    $repoFiles.Name.Contains('CODE_OF_CONDUCT.md') | Should -BeExactly $true
                    $repoFiles.Name.Contains('CONTRIBUTING.md') | Should -BeExactly $true
                    $contributingContentPath = [System.IO.Path]::Combine($outPutPath, '.github', 'CONTRIBUTING.md')
                    $contributingContent = Get-Content -Path $contributingContentPath -Raw
                    $contributingContent | Should -BeLike '*SecretManagement.MyVault*'
                    $repoFiles.Name.Contains('SECURITY.md') | Should -BeExactly $true
                    $securityContentPath = [System.IO.Path]::Combine($outPutPath, '.github', 'SECURITY.md')
                    $securityContent = Get-Content -Path $securityContentPath -Raw
                    $securityContent | Should -BeLike '*SecretManagement.MyVault*'
                    $repoFiles.Name.Contains('.gitignore') | Should -BeExactly $true
                    $repoFiles.Name.Contains('PULL_REQUEST_TEMPLATE.md') | Should -BeExactly $true
                    $repoFiles.Name.Contains('bug-report.md') | Should -BeExactly $true
                    $repoFiles.Name.Contains('feature_request.md') | Should -BeExactly $true

                    $dotGitHubFiles = @(
                        'CODE_OF_CONDUCT.md'
                        'CONTRIBUTING.md'
                        'SECURITY.md'
                        'PULL_REQUEST_TEMPLATE.md'
                        'bug-report.md'
                        'feature_request.md'
                    )
                    $docFiles = @(
                        'CHANGELOG.md'
                    )
                    foreach ($file in $dotGitHubFiles) {
                        ($repoFiles | Where-Object { $_.name -eq $file }).Directory | Should -BeLike '*.github*'
                    }
                    foreach ($file in $docFiles) {
                        ($repoFiles | Where-Object { $_.name -eq $file }).Directory | Should -BeLike '*docs*'
                    }

                } #it

            } #context_github

        } #context_repo

        Context 'Help Examples' {

            It 'should have a working example for vanilla module' {
                $vaultParameters = @{
                    ModuleName  = 'SecretManagement.VaultName'
                    Description = 'My awesome vault is awesome'
                    Version     = '0.0.1'
                    FN          = 'user full name'
                    CICD        = 'NONE'
                    RepoType    = 'NONE'
                    CodingStyle = 'Stroustrup'
                    Pester      = '5'
                    NoLogo      = $true
                }
                New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath

                $manifestContentPath = [System.IO.Path]::Combine($outPutPath, 'src', 'SecretManagement.VaultName', 'SecretManagement.VaultName.psd1')
                $manifestContent = Get-Content -Path $manifestContentPath -Raw
                $manifestContent | Should -BeLike '*My awesome vault is awesome*'
            } #it

            It 'should have a working example for GitHub Actions module' {
                $vaultParameters = @{
                    ModuleName     = 'SecretManagement.VaultName'
                    Description    = 'My awesome vault is awesome'
                    Version        = '0.0.1'
                    FN             = 'user full name'
                    CICD           = 'GITHUB'
                    GitHubAOptions = 'windows', 'pwshcore', 'linux', 'macos'
                    RepoType       = 'GITHUB'
                    License        = 'MIT'
                    Changelog      = 'CHANGELOG'
                    COC            = 'CONDUCT'
                    Contribute     = 'CONTRIBUTING'
                    Security       = 'SECURITY'
                    CodingStyle    = 'Stroustrup'
                    Pester         = '5'
                    S3Bucket       = 'PSGallery'
                    NoLogo         = $true
                }
                New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath

                $manifestContentPath = [System.IO.Path]::Combine($outPutPath, 'src', 'SecretManagement.VaultName', 'SecretManagement.VaultName.psd1')
                $manifestContent = Get-Content -Path $manifestContentPath -Raw
                $manifestContent | Should -BeLike '*My awesome vault is awesome*'
            } #it

            It 'should have a working example for AWS module' {
                $vaultParameters = @{
                    ModuleName  = 'SecretManagement.VaultName'
                    Description = 'My awesome vault is awesome'
                    Version     = '0.0.1'
                    FN          = 'user full name'
                    CICD        = 'CODEBUILD'
                    AWSOptions  = 'ps', 'pwshcore', 'pwsh'
                    RepoType    = 'GITHUB'
                    License     = 'MIT'
                    Changelog   = 'CHANGELOG'
                    COC         = 'CONDUCT'
                    Contribute  = 'CONTRIBUTING'
                    Security    = 'SECURITY'
                    CodingStyle = 'Stroustrup'
                    Pester      = '5'
                    S3Bucket    = 'PSGallery'
                    NoLogo      = $true
                }
                New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath

                $manifestContentPath = [System.IO.Path]::Combine($outPutPath, 'src', 'SecretManagement.VaultName', 'SecretManagement.VaultName.psd1')
                $manifestContent = Get-Content -Path $manifestContentPath -Raw
                $manifestContent | Should -BeLike '*My awesome vault is awesome*'
            } #it

            It 'should have a working example for Azure module' {
                $vaultParameters = @{
                    ModuleName   = 'SecretManagement.VaultName'
                    Description  = 'My awesome vault is awesome'
                    Version      = '0.0.1'
                    FN           = 'user full name'
                    CICD         = 'AZURE'
                    AzureOptions = 'windows', 'pwshcore', 'linux', 'macos'
                    RepoType     = 'GITHUB'
                    License      = 'None'
                    Changelog    = 'NOCHANGELOG'
                    COC          = 'NOCONDUCT'
                    Contribute   = 'NOCONTRIBUTING'
                    Security     = 'NOSECURITY'
                    CodingStyle  = 'Stroustrup'
                    Pester       = '5'
                    NoLogo       = $true
                }
                New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath

                $manifestContentPath = [System.IO.Path]::Combine($outPutPath, 'src', 'SecretManagement.VaultName', 'SecretManagement.VaultName.psd1')
                $manifestContent = Get-Content -Path $manifestContentPath -Raw
                $manifestContent | Should -BeLike '*My awesome vault is awesome*'
            } #it

            It 'should have a working example for Appveyor module' {
                $vaultParameters = @{
                    ModuleName      = 'SecretManagement.VaultName'
                    Description     = 'My awesome vault is awesome'
                    Version         = '0.0.1'
                    FN              = 'user full name'
                    CICD            = 'APPVEYOR'
                    AppveyorOptions = 'windows', 'pwshcore', 'linux', 'macos'
                    RepoType        = 'GITHUB'
                    License         = 'None'
                    Changelog       = 'NOCHANGELOG'
                    COC             = 'NOCONDUCT'
                    Contribute      = 'NOCONTRIBUTING'
                    Security        = 'NOSECURITY'
                    CodingStyle     = 'Stroustrup'
                    Pester          = '5'
                    PassThru        = $true
                    NoLogo          = $true
                }
                New-VaultProject -VaultParameters $vaultParameters -DestinationPath $outPutPath

                $manifestContentPath = [System.IO.Path]::Combine($outPutPath, 'src', 'SecretManagement.VaultName', 'SecretManagement.VaultName.psd1')
                $manifestContent = Get-Content -Path $manifestContentPath -Raw
                $manifestContent | Should -BeLike '*My awesome vault is awesome*'
            } #it
        }

    } #context_module_checks

} #describe_module_tests
