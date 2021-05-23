<# Create a fileWatcher that will monitor the directory and add its attributes#>
$rubyArgs = @('.\data-extractor.rb', 'import') 
ruby $rubyArgs

$Path = ".\Data"
$FileFilter = '*.rxdata'

$Timeout = 1000
$ChangeTypes = [System.IO.WatcherChangeTypes]::Created, [System.IO.WatcherChangeTypes]::Deleted, [System.IO.WatcherChangeTypes]::Changed, [System.IO.WatcherChangeTypes]::Renamed

$IncludeSubfolders = $true
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite

$watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $Path, $FileFilter -Property @{
    IncludeSubdirectories = $IncludeSubfolders
    NotifyFilter = $AttributeFilter
  }
function Do_Stuff {
    param (
        [Parameter(Mandatory)]
        [System.IO.WaitForChangedResult]
        $ChangeInformation
    )
    Start-Sleep(0.1) # Wait for RPG Maker to finish writing
    Write-Warning 'Change detected:'
    $rubyArgs = @('.\data-extractor.rb', 'export')
    ruby $rubyArgs
}


$rpgmakerpath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Classes\RPGXP.Project\shell\open\command\' -Name '(Default)'
$rpgmakerpath = $rpgmakerpath -replace '"%1"', ''
$rpgmakerpath = $rpgmakerpath -replace '"', ''

Write-Output "Opening RPG Maker"

Start-Process $rpgmakerpath '.\game.rxproj' -NoNewWindow
Start-Sleep(1)
$rpgmakeropen = get-process "RPGXP" -ErrorAction SilentlyContinue
while($true) {
    $rpgmakeropen = get-process "RPGXP" -ErrorAction SilentlyContinue
    if ($Null -eq $rpgmakeropen) {
        break #Break from loop of rpg maker is closed
    }
    $result = $watcher.WaitForChanged($ChangeTypes, $Timeout)
    # if there was a timeout, continue monitoring:
    if ($result.TimedOut) { continue }
    Do_Stuff -Change $result
}

Write-Output "RPG Maker closed"

Get-EventSubscriber | Unregister-Event

$watcher.Dispose()

$rubyArgs = @('.\data-extractor.rb', 'import') 
ruby $rubyArgs

