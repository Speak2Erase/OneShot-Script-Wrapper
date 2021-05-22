<# Create a fileWatcher that will monitor the directory and add its attributes#>
$rubyArgs = @('.\data-extractor.rb', 'import') 
ruby $rubyArgs

$fileWatcher = New-Object System.IO.FileSystemWatcher
$fileWatcher.Path = ".\Data\"
$fileWatcher.Filter = "*.rxdata";
$fileWatcher.IncludeSubdirectories = $true
$fileWatcher.EnableRaisingEvents = $true

$action = {
    Write-Host "Changes detected, exporting Data..."
    $rubyArgs = @('.\data-extractor.rb', 'export') 
    ruby $rubyArgs
    Get-Event | Remove-Event
}

Register-ObjectEvent $filewatcher “Created” -Action $action
Register-ObjectEvent $filewatcher “Changed” -Action $action 
Register-ObjectEvent $filewatcher “Deleted” -Action $action 
Register-ObjectEvent $filewatcher “Renamed” -Action $action 

$rpgmakerpath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Classes\RPGXP.Project\shell\open\command\' -Name '(Default)'
$rpgmakerpath = $rpgmakerpath -replace '"%1"', ''
$rpgmakerpath = $rpgmakerpath -replace '"', ''

Write-Output "Opening RPG Maker"

Start-Process $rpgmakerpath '.\game.rxproj' -NoNewWindow
Start-Sleep(1)
$rpgmakeropen = get-process "RPGXP" -ErrorAction SilentlyContinue
while($Null -ne $rpgmakeropen) {
    $rpgmakeropen = get-process "RPGXP" -ErrorAction SilentlyContinue
}

Write-Output "RPG Maker closed"

Get-EventSubscriber | Unregister-Event
$fileWatcher.EnableRaisingEvents = $false
$fileWatcher.Dispose()

$rubyArgs = @('.\data-extractor.rb', 'import') 
ruby $rubyArgs

