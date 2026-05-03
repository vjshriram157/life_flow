$mavenHome = "$PSScriptRoot\apache-maven-3.9.6"
$javaHome = "$PSScriptRoot\jdk-17.0.10+7"

Write-Host "Setting MAVEN_HOME..."
[System.Environment]::SetEnvironmentVariable("MAVEN_HOME", $mavenHome, "User")

Write-Host "Setting JAVA_HOME..."
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "User")

Write-Host "Updating Path..."
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$newBinPaths = @("$mavenHome\bin", "$javaHome\bin")

foreach ($binPath in $newBinPaths) {
    if ($currentPath -notlike "*$binPath*") {
        $currentPath = $currentPath + ";" + $binPath
        Write-Host "Added $binPath to Path."
    } else {
        Write-Host "$binPath is already in Path."
    }
}

[System.Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
Write-Host "Environment variables updated successfully."
