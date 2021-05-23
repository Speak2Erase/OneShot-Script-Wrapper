$rubyArgs = @('.\data-extractor.rb', 'import') #? Import Data_JSON to Data
ruby $rubyArgs
$Path = ".\Data"
$FileFilter = '*.rxdata'
#? Create watcher attributes
$Timeout = 1000
$ChangeTypes = [System.IO.WatcherChangeTypes]::Created, [System.IO.WatcherChangeTypes]::Deleted, [System.IO.WatcherChangeTypes]::Changed, [System.IO.WatcherChangeTypes]::Renamed
$IncludeSubfolders = $true
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite
#? Spawn watcher
$watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $Path, $FileFilter -Property @{
    IncludeSubdirectories = $IncludeSubfolders
    NotifyFilter = $AttributeFilter
  }
function Export {
    param (
        [Parameter(Mandatory)]
        [System.IO.WaitForChangedResult]
        $ChangeInformation
    )
    Start-Sleep(0.1) #! Wait for RPG Maker to finish writing, because I can't think of a better way to go about this
    Write-Warning 'Change detected:'
    $rubyArgs = @('.\data-extractor.rb', 'export') #? Export to Data Data_JSON
    ruby $rubyArgs
}
#? Get path to RPG Maker XP
$rpgmakerpath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Classes\RPGXP.Project\shell\open\command\' -Name '(Default)'
$rpgmakerpath = $rpgmakerpath -replace '"%1"', ''
$rpgmakerpath = $rpgmakerpath -replace '"', ''
Write-Output "Opening RPG Maker"
Start-Process $rpgmakerpath '.\game.rxproj' -NoNewWindow #? Start RPG Maker
Start-Sleep(1) #? Wait for it to open
while($true) {
    $rpgmakeropen = get-process "RPGXP" -ErrorAction SilentlyContinue #? Check if it's open
    if ($Null -eq $rpgmakeropen) {
        break #Break from loop of rpg maker is closed #? Break if it isn't
    }
    $result = $watcher.WaitForChanged($ChangeTypes, $Timeout) #? Get result of file watcher
    #? Continue if no timeout
    if ($result.TimedOut) { continue }
    Export -Change $result #? Called only if no timeout (i.e something happened)
}
Write-Output "RPG Maker closed"
$watcher.Dispose() #? Dispose of watcher
$rubyArgs = @('.\data-extractor.rb', 'export') #? Export to Data Data_JSON
ruby $rubyArgs
#TODO: Call ruby stuff in oneline