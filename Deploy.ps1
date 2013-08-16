param($installPath, $toolsPath, $package, $project)

$thisFolder = get-location
$targetPath = "c:\elasticsearch"
$targetDataPath = "e:\elasticsearch"
$serviceName = "ElasticSearch"



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
    $installExe = $targetPath + "\service\ElasticSearch32.exe"
    $switch = "install"
    $description = '--Description=\"Distributed RESTful Full-Text Search Engine based on Lucene (http://www.elasticsearch.org/)\"'
    $displayName = '--DisplayName="' + $serviceName + '"'
    $installExeArg =  '--Install="' + $installExe + '"'
    $classPath = '--Classpath="' + "$targetPath\lib\elasticsearch-0.16.0.jar;$targetPath\lib\*;$targetPath\lib\sigar\*" + '"'
    $jvmMx = "--JvmMx=512"
    $jvmOptions = '--JvmOptions="-Xms256m;-Xmx1g;-Xss128k;-XX:+UseParNewGC;-XX:+UseConcMarkSweepGC;-XX:+CMSParallelRemarkEnabled;-XX:SurvivorRatio=8;-XX:MaxTenuringThreshold=1;-XX:CMSInitiatingOccupancyFraction=75;-XX:+UseCMSInitiatingOccupancyOnly;-XX:+HeapDumpOnOutOfMemoryError;-Djline.enabled=false;-Delasticsearch;-Des-foreground=yes;-Des.path.home=' + $targetPath + '"'
    $startMode = "--StartMode=jvm"
    $startClass = '--StartClass=org.elasticsearch.bootstrap.Bootstrap'
    $startMethod = '--StartMethod=main'
    $startParams = '--StartParams=\"\"'
    $stopMode = '--StopMode=jvm'
    $stopClass = '--StopClass=org.elasticsearch.bootstrap.Bootstrap'
    $stopMethod = '--StopMethod=close'
    $stdOutput = '--StdOutput=auto'
    $stdError = '--StdError=auto'
    $stdLogLevel = '--LogLevel=Warning'
    $logPath = '--LogPath="' + "$targetDataPath\logs" + '"'
    $logPrefix = '--LogPrefix=service'
    $startUp = '--Startup=auto'
    $allArgs = @($switch, $serviceName, $displayName, $description, 
        $installExeArg, $classPath, $jvmMx, $jvmOptions,
        $startMode, $startClass, $startMethod,  $startParams,
        $stopMode, $stopClass, $stopMethod, $stdOutput, 
        $stdError, $stdLogLevel, $logPath, $logPrefix,
        $startUp)

    $args = [string]::join(' ', $allArgs)
    Write-Host $args

    & $installExe $allArgs
}

function StartService {
    $service = Get-Service $serviceName
    $service.Start()
}

function Install-ElasticSearch($pathOfScript) {
    CreateFolders
    CopyElasticSearch $pathOfScript
    RunInstall
    StartService
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
