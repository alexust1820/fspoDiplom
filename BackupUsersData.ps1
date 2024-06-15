Add-Type -AssemblyName "System.IO.Compression.FileSystem"

$Date = Get-Date -Format "yyyyMMdd_HHmmss"
$SourceDir = "C:\FSPOSUAI"
$BackupDir = "$(Join-Path -Path "D:\Backups" -ChildPath $Date).zip"

if ((Test-Path -Path $SourceDir) -and (Test-Path -Path "D:\Backups")) {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir, $BackupDir)
}