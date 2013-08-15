param($installPath, $toolsPath, $package, $project)

$thisFolder = get-location
$targetPath = "c:\\elasticsearch"
$targetDataPath = "e:\\elasticsearch"

function CreateFolders {
    if((test-path $targetDataPath) -eq $false) {
        New-Item -ItemType directory -Path targetPath
        New-Item -ItemType directory -Path "$targetDataPath\logs"
    }
}

function CopyElasticSearch($pathOfScript) {
    Write-Host "Copying files"
    $sourceFolder = "$pathOfScript"
    Copy-Item -Path $sourceFolder -Destination $targetPath -Recurse -Force
}

function RunInstall {
    $installCmd = $targetPath + "\\service\\"
    cd $installCmd
    .\Install.cmd
}

function Install-ElasticSearch($pathOfScript) {
    CreateFolders
    CopyElasticSearch $pathOfScript
    RunInstall
}

$service = get-service | where { $_.Name -eq "ElasticSearch"}
$currentPath = split-path -parent $MyInvocation.MyCommand.Definition
Write-Host "Current path: $currentPath"
if($service -eq $null) {
    Write-Host "ElasticSearch not installed, installing"
    try {
        Install-ElasticSearch $currentPath        
    }
    catch {
        Write-Host "Failed to install: ElasticSearch"
        Exit 1
    }
    finally {
        cd $thisFolder
    }
}
else {
    Write-Host "Service already installed"
}