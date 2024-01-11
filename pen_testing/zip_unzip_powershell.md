# Code block of powershell unzip and zip from my YT video

## `Add-Type` Method

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

unzip "C:\path\to\file.zip" "C:\path\to\extract\dir\"

Add-Type -AssemblyName System.IO.Compression.FileSystem
function ZipFiles
{
    param([string]$zipfile, [string]$sourcefolder)
    [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcefolder, $zipfile)
}

ZipFiles "C:\a.zip" "C:\a"
```

## Powershell version 5 CMDLET Method

```powershell
Compress-Archive -Path "C:\Path\To\Your\Folder" -DestinationPath "C:\Path\To\Your\Archive.zip"
Expand-Archive -Path "C:\Path\To\Your\Archive.zip" -DestinationPath "C:\Path\To\Extract\Here"
```
