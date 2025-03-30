#!/usr/bin/env pwsh

# =========== Created with CLI version 1.12.0 ===========

function Exec {
    param (
        [scriptblock]$ScriptBlock
    )
    & @ScriptBlock
    if ($lastexitcode -ne 0) {
        exit $lastexitcode
    }
}

function ExecAndGetMigrationID {
    param (
        [scriptblock]$ScriptBlock
    )
    $MigrationID = & @ScriptBlock | ForEach-Object {
        Write-Host $_
        $_
    } | Select-String -Pattern "\(ID: (.+)\)" | ForEach-Object { $_.matches.groups[1] }
    return $MigrationID
}

function ExecBatch {
    param (
        [scriptblock[]]$ScriptBlocks
    )
    $Global:LastBatchFailures = 0
    foreach ($ScriptBlock in $ScriptBlocks)
    {
        & @ScriptBlock
        if ($lastexitcode -ne 0) {
            $Global:LastBatchFailures++
        }
    }
}

if (-not $env:ADO_PAT) {
    Write-Error "ADO_PAT environment variable must be set to a valid Azure DevOps Personal Access Token with the appropriate scopes. For more information see https://docs.github.com/en/migrations/using-github-enterprise-importer/preparing-to-migrate-with-github-enterprise-importer/managing-access-for-github-enterprise-importer#personal-access-tokens-for-azure-devops"
    exit 1
} else {
    Write-Host "ADO_PAT environment variable is set and will be used to authenticate to Azure DevOps."
}

if (-not $env:GH_PAT) {
    Write-Error "GH_PAT environment variable must be set to a valid GitHub Personal Access Token with the appropriate scopes. For more information see https://docs.github.com/en/migrations/using-github-enterprise-importer/preparing-to-migrate-with-github-enterprise-importer/managing-access-for-github-enterprise-importer#creating-a-personal-access-token-for-github-enterprise-importer"
    exit 1
} else {
    Write-Host "GH_PAT environment variable is set and will be used to authenticate to GitHub."
}

$Succeeded = 0
$Failed = 0
$RepoMigrations = [ordered]@{}

# =========== Queueing migration for Organization: prashanthkool7 ===========

# === Queueing repo migrations for Team Project: prashanthkool7/Prashanth_Test ===

$MigrationID = ExecAndGetMigrationID { gh ado2gh migrate-repo --ado-org "prashanthkool7" --ado-team-project "Prashanth_Test" --ado-repo "Prashanth_Test" --github-org "RocketResume-ai" --github-repo "Prashanth_Test-Prashanth_Test" --queue-only --target-repo-visibility private }
$RepoMigrations["prashanthkool7/Prashanth_Test-Prashanth_Test"] = $MigrationID

# === Queueing repo migrations for Team Project: prashanthkool7/satish_test ===

$MigrationID = ExecAndGetMigrationID { gh ado2gh migrate-repo --ado-org "prashanthkool7" --ado-team-project "satish_test" --ado-repo "satish_test" --github-org "RocketResume-ai" --github-repo "satish_test-satish_test" --queue-only --target-repo-visibility private }
$RepoMigrations["prashanthkool7/satish_test-satish_test"] = $MigrationID

# =========== Waiting for all migrations to finish for Organization: prashanthkool7 ===========

# === Waiting for repo migration to finish for Team Project: Prashanth_Test and Repo: Prashanth_Test. Will then complete the below post migration steps. ===
$CanExecuteBatch = $false
if ($null -ne $RepoMigrations["prashanthkool7/Prashanth_Test-Prashanth_Test"]) {
    gh ado2gh wait-for-migration --migration-id $RepoMigrations["prashanthkool7/Prashanth_Test-Prashanth_Test"]
    $CanExecuteBatch = ($lastexitcode -eq 0)
}
if ($CanExecuteBatch) {
    $Succeeded++
} else {
    $Failed++
}

# === Waiting for repo migration to finish for Team Project: satish_test and Repo: satish_test. Will then complete the below post migration steps. ===
$CanExecuteBatch = $false
if ($null -ne $RepoMigrations["prashanthkool7/satish_test-satish_test"]) {
    gh ado2gh wait-for-migration --migration-id $RepoMigrations["prashanthkool7/satish_test-satish_test"]
    $CanExecuteBatch = ($lastexitcode -eq 0)
}
if ($CanExecuteBatch) {
    $Succeeded++
} else {
    $Failed++
}

Write-Host =============== Summary ===============
Write-Host Total number of successful migrations: $Succeeded
Write-Host Total number of failed migrations: $Failed

if ($Failed -ne 0) {
    exit 1
}


