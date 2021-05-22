<# Create a fileWatcher that will monitor the directory and add its attributes#>
$rubyArgs = @('.\data-extractor.rb', 'import') 
ruby $rubyArgs

$fileWatcher = new-object System.IO.FileSystemWatcher
$fileWatcher.Path = ".\Data"
$fileWatcher.Filter = "*.rxdata";
$fileWatcher.IncludeSubdirectories = $true
$fileWatcher.EnableRaisingEvents = $true

$action = {
    $rubyArgs = @('.\data-extractor.rb', 'export') 
    ruby $rubyArgs | Write-Output
}

Register-ObjectEvent $filewatcher “Created” -Action $action | Out-Null
Register-ObjectEvent $filewatcher “Changed” -Action $action | Out-Null
Register-ObjectEvent $filewatcher “Deleted” -Action $action | Out-Null
Register-ObjectEvent $filewatcher “Renamed” -Action $action | Out-Null

$rpgmakerpath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Classes\RPGXP.Project\shell\open\command\' -Name '(Default)'
$rpgmakerpath = $rpgmakerpath -replace '"%1"', ''
$rpgmakerpath = $rpgmakerpath -replace '"', ''

Write-Output "Opening RPG Maker"

Start-Process $rpgmakerpath '.\game.rxproj' -NoNewWindow -Wait

Write-Output "RPG Maker closed"

$rubyArgs = @('.\data-extractor.rb', 'import') 
ruby $rubyArgs

Get-EventSubscriber | Unregister-Event
