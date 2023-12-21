<#
.SYNOPSIS
    This script modifies a configuration line in an specific file passed as paremeter

.DESCRIPTION

This script has 4 parameters: 

    1. File path: Full path of a file to modify
    2. String: Representing an existing config file line 
    3. String: Representing a new config file line to replace the config file line of parameter 2
        a. If this parameter is empty, it will indicate the script to DELETE the existing config file line of parameter 2. 
    4. Boolean: Representing a flag for “Dry mode”

The script then:

    If run on dry mode
        1. Search for the line (2) in the file specified by path (1).
        2. If found, it will output the line and the intended modification
        3. If not found, it will output “Line not found on file”

    If not run on dry mode:
        1. Perform a backup of the file specified in the path
        2. Search for the line (2) in the file specified by path (1)
        3. Replace found line (1) with line specified on (3), or delete if (3) is an empty string
        4. Output the line found and the line replaced with format Line %lineFound replaced by %replacementLine on line %LineNumber

    
.EXAMPLE
    
    PS C:\> configUpdater.ps1 [File Path] -SourceContent [Old Config String] -destContent [New Config String (Optional)] -Dry (Optional) 

.NOTES
    Author: Carlos Breininger

.LINK
#>

[CmdletBinding()]

param(
        [Parameter(mandatory=$true)]
        [String] $filePath,
        [Parameter(mandatory=$true)]
        [string] $sourceContent,
        [Parameter(mandatory=$false)]
        [string] $destContent,
        [Parameter(mandatory=$false)]
        [switch] $dry=$false 
)

begin{
    #test filePath
    if (-not $(Test-Path $filePath)) {
        Write-Host "'$($filePath)' is not a valid path. Please check it before run this script again" -ForegroundColor Red
        Break
    }
    #check if sourceContent is a line
    $sourceLine = Get-Content $filePath | sls $sourceContent
    if (-Not $sourceLine) {
        write-host "Line not found in file" -ForegroundColor Red
        Break      
    } elseif ($sourceLine.ToString().Trim() -cnotlike $sourceContent) {
        write-host "Line is not a full line" -ForegroundColor Red
        Break
    }
}

process {
    # Main script loop here
    if (-Not $dry) {
        Copy-Item -LiteralPath $filePath -Destination "$($filePath).bkp$((Get-Date).ToString("yyyyMMdd"))" -Force
        Write-Host "$($sourceLine) replaced by $($destContent) on line $($sourceLine.LineNumber)"
        if ($destContent) { 
            (Get-Content $filePath).replace($sourceContent,$destContent) | Set-Content $filePath
        } else { 
            (Get-Content $filePath | Where-Object ReadCount -notin $sourceLine.LineNumber) | Set-Content $filePath
        }
    } else {
        if ($destContent) {
            write-host "Line:$($sourceLine.LineNumber) -$($sourceContent) will be replaced by $($destContent)"
        } else {write-host "Line:$($sourceLine.LineNumber) -$($sourceContent) will be deleted"}
}

end {
    # One-time post processing operations
    }
} 