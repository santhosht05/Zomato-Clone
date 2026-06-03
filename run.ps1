# ==============================================================================
# SwadhaFood (Zomato Clone) - Automated Build & Launch Script
# ==============================================================================

$ErrorActionPreference = "Stop"
$PSScriptRoot = Get-Location

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Starting SwadhaFood Local Build & Deployment Process" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Setup Database Schema
# ------------------------------------------------------------------------------
Write-Host "`n[1/5] Checking MySQL Database..." -ForegroundColor Green
$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if (Test-Path $mysqlPath) {
    try {
        Write-Host "Found local MySQL. Importing database/swadhafood.sql..." -ForegroundColor Gray
        Get-Content "$PSScriptRoot\database\swadhafood.sql" -Raw | & $mysqlPath -u root -p"Santhosht@8"
        Write-Host "[OK] Database swadhafood created and populated successfully!" -ForegroundColor Green
    } catch {
        try {
            Write-Host "Import failed with 'Santhosht@8', trying fallback password 'root'..." -ForegroundColor Yellow
            Get-Content "$PSScriptRoot\database\swadhafood.sql" -Raw | & $mysqlPath -u root -proot
            Write-Host "[OK] Database swadhafood created and populated successfully with fallback!" -ForegroundColor Green
        } catch {
            Write-Host "[WARNING] Database import failed. Make sure MySQL is running with correct credentials." -ForegroundColor Yellow
            Write-Host "Details: $_" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host "[WARNING] mysql.exe not found at default path. Please make sure to import database/swadhafood.sql manually." -ForegroundColor Yellow
}

# Create a local build sandbox to keep the workspace clean
$sandboxDir = Join-Path $PSScriptRoot "tomcat-setup"
if (!(Test-Path $sandboxDir)) {
    New-Item -ItemType Directory -Path $sandboxDir | Out-Null
}

# ------------------------------------------------------------------------------
# 2. Setup Portable Maven
# ------------------------------------------------------------------------------
Write-Host "`n[2/5] Setting up Portable Maven environment..." -ForegroundColor Green
$mavenDirName = "apache-maven-3.9.6"
$mavenZipName = "apache-maven-3.9.6-bin.zip"
$mavenZipPath = Join-Path $sandboxDir $mavenZipName
$mavenExtractPath = Join-Path $sandboxDir $mavenDirName

if (!(Test-Path $mavenExtractPath)) {
    Write-Host "Downloading Maven from Apache archives (approx 9MB)..." -ForegroundColor Gray
    $mavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
    Invoke-WebRequest -Uri $mavenUrl -OutFile $mavenZipPath
    
    Write-Host "Extracting Maven..." -ForegroundColor Gray
    Expand-Archive -Path $mavenZipPath -DestinationPath $sandboxDir -Force
    Remove-Item $mavenZipPath -Force
    Write-Host "[OK] Maven installed." -ForegroundColor Green
} else {
    Write-Host "[OK] Maven already installed." -ForegroundColor Green
}

$mvnCmd = Join-Path $sandboxDir "$mavenDirName\bin\mvn.cmd"

# ------------------------------------------------------------------------------
# 3. Setup Portable Tomcat 10
# ------------------------------------------------------------------------------
Write-Host "`n[3/5] Setting up Portable Apache Tomcat 10..." -ForegroundColor Green
$tomcatDirName = "apache-tomcat-10.1.20"
$tomcatZipName = "apache-tomcat-10.1.20-windows-x64.zip"
$tomcatZipPath = Join-Path $sandboxDir $tomcatZipName
$tomcatExtractPath = Join-Path $sandboxDir $tomcatDirName

if (!(Test-Path $tomcatExtractPath)) {
    Write-Host "Downloading Apache Tomcat 10 from Apache archives (approx 13MB)..." -ForegroundColor Gray
    $tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.20/bin/apache-tomcat-10.1.20-windows-x64.zip"
    Invoke-WebRequest -Uri $tomcatUrl -OutFile $tomcatZipPath
    
    Write-Host "Extracting Tomcat 10..." -ForegroundColor Gray
    Expand-Archive -Path $tomcatZipPath -DestinationPath $sandboxDir -Force
    Remove-Item $tomcatZipPath -Force
    Write-Host "[OK] Tomcat 10 installed." -ForegroundColor Green
} else {
    Write-Host "[OK] Tomcat already installed." -ForegroundColor Green
}

$tomcatWebappsDir = Join-Path $tomcatExtractPath "webapps"
$tomcatBinDir = Join-Path $tomcatExtractPath "bin"

# ------------------------------------------------------------------------------
# 3b. Configure Port 8081 to avoid conflict with existing local Tomcat
# ------------------------------------------------------------------------------
Write-Host "Configuring Tomcat to run on port 8081 (preventing port 8080 conflicts)..." -ForegroundColor Gray
$serverXml = Join-Path $tomcatExtractPath "conf\server.xml"
if (Test-Path $serverXml) {
    (Get-Content $serverXml) -replace 'port="8080"', 'port="8081"' -replace 'port="8005"', 'port="8006"' | Set-Content $serverXml
    Write-Host "[OK] Port configured to 8081." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 4. Compile and Package Application via Maven
# ------------------------------------------------------------------------------
Write-Host "`n[4/5] Compiling and Packaging SwadhaFood..." -ForegroundColor Green
Write-Host "Running: mvn clean package" -ForegroundColor Gray
& $mvnCmd clean package

$warFile = Join-Path $PSScriptRoot "target\swadhafood.war"
if (Test-Path $warFile) {
    Write-Host "[OK] Application compiled and packaged into target/swadhafood.war" -ForegroundColor Green
    
    # Deploying WAR to Tomcat Webapps
    Write-Host "Deploying to Tomcat webapps..." -ForegroundColor Gray
    $targetDeployment = Join-Path $tomcatWebappsDir "swadhafood.war"
    Copy-Item $warFile $targetDeployment -Force
    Write-Host "[OK] Deployment configured." -ForegroundColor Green
} else {
    Write-Host "[ERROR] target/swadhafood.war could not be found. Compilation failed." -ForegroundColor Red
    Exit
}

# ------------------------------------------------------------------------------
# 5. Start Tomcat Server and Open Web Page
# ------------------------------------------------------------------------------
Write-Host "`n[5/5] Starting Apache Tomcat Server on port 8081..." -ForegroundColor Green
$startupBat = Join-Path $tomcatBinDir "startup.bat"

# Start Tomcat in a separate cmd window
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$startupBat`"" -WorkingDirectory $tomcatBinDir

Write-Host "Tomcat server is starting up in a separate terminal window..." -ForegroundColor Gray
Write-Host "Waiting 5 seconds for initialization..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Open browser to the landing page on port 8081
$url = "http://localhost:8081/swadhafood/"
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "SwadhaFood is running live!" -ForegroundColor Green
Write-Host "Access the app at: $url" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Start-Process $url
