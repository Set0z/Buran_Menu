#region Объявление переменных
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Менеджер встроенных приложений ⚙️"} else {$host.ui.RawUI.WindowTitle = "System Apps Manager ⚙️"})
$scriptDir = $PSScriptRoot
$uiLang = (Get-Culture).Name 
$Menu_Lang = $env:BURAN_lang
if ($PSScriptRoot -eq "") {Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking} else {$scriptDir = $PSScriptRoot ; Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking}
if (-not $global:AllPackages) {$global:AllPackages = Get-AppxPackage -AllUsers}

$grn = "$([char]27)[48;5;0;38;5;2m"   # черный фон, зеленый текст
$purp = "$([char]27)[48;5;0;38;5;13m"   # черный фон, фиолетовый текст
$red = "$([char]27)[48;5;0;38;5;1m"   # чёрный фон, красный текст

$sel = "$([char]27)[48;5;2;38;5;0m"   # зелёный фон, черный текст, выделенный
$selred = "$([char]27)[48;5;1;38;5;0m"   # красный фон, черный текст, выделенный
$selpurp = "$([char]27)[48;5;13;38;5;0m"   # фиолетовый фон, черный текст, выделенный

$XboxPackages = @(
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider"
)

#endregion

#region Функции

function Removing{
    param (
        [string]$Page
    )
    if(($OneDriveSelected) -or ($CortanaSelected) -or ($OneNoteSelected) -or ($SkypeSelected) -or ($StoreSelected) -or ($NotesSelected) -or ($XboxSelected) -or ($OfficeHubSelected) -or ($SolitaireSelected) -or ($ClipchampSelected) -or ($OutlookSelected) -or ($TeamsSelected) -or ($TodoSelected) -or ($DevHomeSelected) -or ($PowerAutomateSelected) -or ($CalcSelected) -or ($ZuneMusicSelected) -or ($PhotoSelected) -or ($SketchSelected) -or ($AlarmsSelected) -or ($Paint3dSelected) -or ($RecorderSelected) -or ($CameraSelected) -or ($WeatherSelected) -or ($PhoneSelected) -or ($HelpSelected) -or ($FeedbackSelected) -or ($NotepadSelected) -or ($AssistSelected) -or ($NewsSelected) -or ($PortalSelected) -or ($GetstartedSelected) -or ($MailSelected) -or ($PeopleSelected) -or ($3DViewerSelected) -or ($MapsSelected) -or ($ZuneVideoSelected)){
        Clear-Host
        Draw-Banner
        Write-Host "`n`n`n`n`n`n"
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выполняется…"} else {"In progress…"})"

        $old=$ProgressPreference; $ProgressPreference='SilentlyContinue'
        

        

        
        if ($OneDriveSelected) {
            if (Test-Path "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe") {
                try {
                    Start-Process -FilePath "C:\Windows\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -RedirectStandardOutput "C:\Logs\OneDriveUninstall.log" -RedirectStandardError "C:\Logs\OneDriveUninstall.err" -WindowStyle Hidden -ErrorAction Stop
                } catch {
                    Start-Process -FilePath "C:\Windows\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -RedirectStandardOutput "C:\Logs\OneDriveUninstall.log" -RedirectStandardError "C:\Logs\OneDriveUninstall.err" -WindowStyle Hidden -ErrorAction SilentlyContinue
                }
                Start-Sleep -Seconds 5
                if (Test-Path "$env:LocalAppData\Microsoft\OneDrive\OneDrive.exe") {
                    try {
                        Start-Process -FilePath "C:\Windows\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -RedirectStandardOutput "C:\Logs\OneDriveUninstall.log" -RedirectStandardError "C:\Logs\OneDriveUninstall.err" -WindowStyle Hidden -ErrorAction Stop
                    } catch {
                        Start-Process -FilePath "C:\Windows\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -RedirectStandardOutput "C:\Logs\OneDriveUninstall.log" -RedirectStandardError "C:\Logs\OneDriveUninstall.err" -WindowStyle Hidden -ErrorAction SilentlyContinue
                    }
                }
            } else {
                try {
                    Start-Process -FilePath "C:\Windows\SysWOW64\OneDriveSetup.exe" -ArgumentList "/silent" -Wait -RedirectStandardOutput "C:\Logs\OneDriveUninstall.log" -RedirectStandardError "C:\Logs\OneDriveUninstall.err" -WindowStyle Hidden -ErrorAction Stop
                } catch {
                    Start-Process -FilePath "C:\Windows\System32\OneDriveSetup.exe" -ArgumentList "/silent" -Wait -RedirectStandardOutput "C:\Logs\OneDriveUninstall.log" -RedirectStandardError "C:\Logs\OneDriveUninstall.err" -WindowStyle Hidden -ErrorAction SilentlyContinue
                }
            }
            if($PermanentMode){
                if(Test-Path "C:\Windows\SysWOW64\OneDriveSetup.exe"){
                    $OneDrivePath = "C:\Windows\SysWOW64\OneDriveSetup.exe"
                    takeown /f $OneDrivePath > $null 2>&1
                    icacls $OneDrivePath /grant "$($env:USERNAME):F" /t > $null 2>&1
                    Remove-Item $OneDrivePath -Force -ErrorAction SilentlyContinue
                    Remove-Item -Recurse $env:USERPROFILE\OneDrive -Force -ErrorAction SilentlyContinue
                } elseif(Test-Path "C:\Windows\System32\OneDriveSetup.exe") {
                    $OneDrivePath = "C:\Windows\System32\OneDriveSetup.exe"
                    takeown /f $OneDrivePath > $null 2>&1
                    icacls $OneDrivePath /grant "$($env:USERNAME):F" /t > $null 2>&1
                    Remove-Item $OneDrivePath -Force -ErrorAction SilentlyContinue
                    Remove-Item -Recurse $env:USERPROFILE\OneDrive -Force -ErrorAction SilentlyContinue
                }
            } ; $OneDrive = $false}





        if ($CortanaSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Cortana.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Cortana.HasUser) {Add-AppxPackage -Register "$($Cortana.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Cortana.Name)" | Remove-AppxPackage}}
        if ($OneNoteSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($OneNote.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $OneNote.HasUser) {Add-AppxPackage -Register "$($OneNote.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($OneNote.Name)" | Remove-AppxPackage}}
        if ($SkypeSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Skype.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Skype.HasUser) {Add-AppxPackage -Register "$($Skype.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Skype.Name)" | Remove-AppxPackage}}
        if ($StoreSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Store.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Store.HasUser) {Add-AppxPackage -Register "$($Store.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Store.Name)" | Remove-AppxPackage}}
        if ($NotesSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Notes.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Notes.HasUser) {Add-AppxPackage -Register "$($Notes.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Notes.Name)" | Remove-AppxPackage}}
        if ($XboxSelected) {if ($PermanentMode){foreach ($pkg in $XboxPackages) {try{Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like "*$pkg*"} | Remove-AppxProvisionedPackage -Online > $null} catch{}}Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0}if (-not $Xbox.HasUser) {foreach ($pkg in $XboxPackages) {$packagepath = (Get-AppxPackage -AllUsers -Name "*$pkg*").InstallLocation ; $packagepath = $packagepath + "\AppxManifest.xml" ; try {Add-AppxPackage -Register "$($packagepath)" -DisableDevelopmentMode} catch {}}Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 1} else {foreach ($pkg in $XboxPackages) {try {Get-AppxPackage -Name "*$pkg*" | Remove-AppxPackage} catch {}}Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0}}
        if ($OfficeHubSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($OfficeHub.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $OfficeHub.HasUser) {Add-AppxPackage -Register "$($OfficeHub.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($OfficeHub.Name)" | Remove-AppxPackage}}
        if ($SolitaireSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Solitaire.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Solitaire.HasUser) {Add-AppxPackage -Register "$($Solitaire.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Solitaire.Name)" | Remove-AppxPackage}}
        if ($ClipchampSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Clipchamp.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Clipchamp.HasUser) {Add-AppxPackage -Register "$($Clipchamp.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Clipchamp.Name)" | Remove-AppxPackage}}
        if ($OutlookSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Outlook.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Outlook.HasUser) {Add-AppxPackage -Register "$($Outlook.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Outlook.Name)" | Remove-AppxPackage}}
        if ($TeamsSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Teams.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Teams.HasUser) {Add-AppxPackage -Register "$($Teams.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Teams.Name)" | Remove-AppxPackage}}
        if ($TodoSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Todo.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $Todo.HasUser) {Add-AppxPackage -Register "$($Todo.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Todo.Name)" | Remove-AppxPackage}}
        if ($DevHomeSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($DevHome.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $DevHome.HasUser) {Add-AppxPackage -Register "$($DevHome.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($DevHome.Name)" | Remove-AppxPackage}}
        if ($PowerAutomateSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($PowerAutomate.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if (-not $PowerAutomate.HasUser) {try {Add-AppxPackage -Register "$($PowerAutomate.Path)" -DisableDevelopmentMode} catch {}} else {Get-AppxPackage -Name "$($PowerAutomate.Name)" | Remove-AppxPackage}}

        if ($CalcSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Calc.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Calc.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Calc.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Calc.Name)" | Remove-AppxPackage}}
        if ($ZuneMusicSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($ZuneMusic.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $ZuneMusic.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($ZuneMusic.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($ZuneMusic.Name)" | Remove-AppxPackage}}
        if ($PhotoSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Photo.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Photo.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Photo.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Photo.Name)" | Remove-AppxPackage}}
        if ($SketchSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Sketch.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Sketch.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Sketch.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Sketch.Name)" | Remove-AppxPackage}}
        if ($AlarmsSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Alarms.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Alarms.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Alarms.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Alarms.Name)" | Remove-AppxPackage}}
        if ($Paint3dSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Paint3d.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Paint3d.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Paint3d.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Paint3d.Name)" | Remove-AppxPackage}}
        if ($RecorderSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Recorder.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Recorder.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Recorder.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Recorder.Name)" | Remove-AppxPackage}}
        if ($CameraSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Camera.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Camera.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Camera.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Camera.Name)" | Remove-AppxPackage}}
        if ($WeatherSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Weather.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Weather.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Weather.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Weather.Name)" | Remove-AppxPackage}}
        if ($PhoneSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Phone.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Phone.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Phone.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Phone.Name)" | Remove-AppxPackage}}
        if ($HelpSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Help.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Help.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Help.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Help.Name)" | Remove-AppxPackage}}
        if ($FeedbackSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Feedback.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Feedback.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Feedback.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Feedback.Name)" | Remove-AppxPackage}}
        if ($NotepadSelected) {if ($uiLang -like "ru*") {$ShortcutName = "Блокнот.lnk"} else {$ShortcutName = "Notepad.lnk"} if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Notepad.Name)"} | Remove-AppxProvisionedPackage -Online  > $null ; $StartMenuPath = [Environment]::GetFolderPath('StartMenu') ; $Shortcut = $(New-Object -ComObject WScript.Shell).CreateShortcut("$StartMenuPath\$ShortcutName") ; $Shortcut.TargetPath = "C:\Windows\System32\notepad.exe" ; $Shortcut.Save()} if ((-not $Notepad.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Notepad.Path)" -DisableDevelopmentMode ; if (Test-Path "$StartMenuPath\$ShortcutName") {try {Remove-Item "$StartMenuPath\$ShortcutName"} catch{}}} else {Get-AppxPackage -Name "$($Notepad.Name)" | Remove-AppxPackage ; $StartMenuPath = [Environment]::GetFolderPath('StartMenu') ; $Shortcut = $(New-Object -ComObject WScript.Shell).CreateShortcut("$StartMenuPath\$ShortcutName") ; $Shortcut.TargetPath = "C:\Windows\System32\notepad.exe" ; $Shortcut.Save()}}
        if ($AssistSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Assist.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Assist.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Assist.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Assist.Name)" | Remove-AppxPackage}}
        if ($NewsSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($News.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $News.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($News.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($News.Name)" | Remove-AppxPackage}}
        if ($PortalSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Portal.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Portal.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Portal.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Portal.Name)" | Remove-AppxPackage}}
        if ($GetstartedSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Getstarted.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Getstarted.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Getstarted.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Getstarted.Name)" | Remove-AppxPackage}}
        if ($MailSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Mail.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Mail.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Mail.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Mail.Name)" | Remove-AppxPackage}}
        if ($PeopleSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($People.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $People.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($People.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($People.Name)" | Remove-AppxPackage}}
        if ($3DViewerSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($3DViewer.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $3DViewer.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($3DViewer.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($3DViewer.Name)" | Remove-AppxPackage}}
        if ($MapsSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($Maps.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $Maps.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($Maps.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($Maps.Name)" | Remove-AppxPackage}}
        if ($ZuneVideoSelected) {if ($PermanentMode){Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "$($ZuneVideo.Name)"} | Remove-AppxProvisionedPackage -Online  > $null}if ((-not $ZuneVideo.HasUser)-and(-not $PermanentMode)) {Add-AppxPackage -Register "$($ZuneVideo.Path)" -DisableDevelopmentMode} else {Get-AppxPackage -Name "$($ZuneVideo.Name)" | Remove-AppxPackage}}
        $ProgressPreference=$old
        Clear-Host
        Draw-Banner
        Write-Host "`n`n`n`n`n`n"
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})"
        pause

        $OneDriveSelected = $false
        $CortanaSelected = $false
        $OneNoteSelected = $false
        $SkypeSelected = $false
        $StoreSelected = $false
        $NotesSelected = $false
        $XboxSelected = $false
        $OfficeHubSelected = $false
        $SolitaireSelected = $false
        $ClipchampSelected = $false
        $OutlookSelected = $false
        $TeamsSelected = $false
        $TodoSelected = $false
        $DevHomeSelected = $false
        $PowerAutomateSelected = $false
        $CalcSelected = $false
        $ZuneMusicSelected = $false
        $PhotoSelected = $false
        $SketchSelected = $false
        $AlarmsSelected = $false
        $Paint3dSelected = $false
        $RecorderSelected = $false
        $CameraSelected = $false
        $WeatherSelected = $false
        $PhoneSelected = $false
        $HelpSelected = $false
        $FeedbackSelected = $false
        $NotepadSelected = $false
        $AssistSelected = $false
        $NewsSelected = $false
        $PortalSelected = $false
        $GetstartedSelected = $false
        $MailSelected = $false
        $PeopleSelected = $false
        $3DViewerSelected = $false
        $MapsSelected = $false
        $ZuneVideoSelected = $false

        $global:AllPackages = Get-AppxPackage -AllUsers

        if($page -eq "page_1"){Action_choose} elseif ($page -eq "page_2"){Page_two} elseif ($page -eq "base_page_1"){Basic_programs} elseif ($page -eq "base_page_2"){Base_page_two} elseif ($page -eq "base_page_3"){Base_page_three}
    }
}

function Test-AppxPackagePresence {
    param(
        [Parameter(Mandatory)]
        [string[]]$Names  # теперь можно передавать несколько имён
    )

    $existsAll = $null
    foreach ($name in $Names) {
        $found = $global:AllPackages | Where-Object { $_.Name -like "*$name*" -and $_.Name -ne "Microsoft.XboxGameCallableUI" }
        if ($found) {
            $existsAll = $found
            break
        }
    }

    if ($existsAll) {
        $existsUser = $false
        foreach ($name in $Names) {
            if (Get-AppxPackage -Name "*$name*") { 
                $existsUser = $true
                break
            }
        }

        $name = $existsAll[0].Name
        $path = $existsAll[0].InstallLocation
        return [PSCustomObject]@{
            HasAllUsers = $true
            HasUser     = $existsUser
            Name        = $name
            Path        = $path + "\AppxManifest.xml"
        }
    }
    else {
        return [PSCustomObject]@{
            HasAllUsers = $false
            HasUser     = $false
        }
    }
}

function Action_choose{
    
    #region Базовые программы
    function Basic_programs{
        
        #region Вторая страница базовых программ
        function Base_page_two{
            
            

            $Weather = Test-AppxPackagePresence "Microsoft.BingWeather"
            $Phone = Test-AppxPackagePresence "Microsoft.YourPhone"
            $Help = Test-AppxPackagePresence "Microsoft.GetHelp"
            $Feedback = Test-AppxPackagePresence "Microsoft.WindowsFeedbackHub"
            $Notepad = Test-AppxPackagePresence "Microsoft.WindowsNotepad"
            $Assist = Test-AppxPackagePresence "MicrosoftCorporationII.QuickAssist"
            $News = Test-AppxPackagePresence "Microsoft.BingNews"
            $Portal = Test-AppxPackagePresence "Microsoft.MixedReality.Portal"



            Draw-Banner
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
            Align-TextCenter "$(if($Weather.HasAllUsers){$(if($Weather.HasUser){"$(if ($WeatherSelected){"$sel[1]$grn"}else{"[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Погода"} else {"Weather"})$grn"} else {"$(if ($WeatherSelected){"$sel[1]$red"}else{"$red[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Погода"} else {"Weather"})$grn"})} else {"$red[1] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Погода"} else {"Not Found | Weather"})$grn"})"
            Align-TextCenter "$(if($Phone.HasAllUsers){$(if($Phone.HasUser){"$(if ($PhoneSelected){"$sel[2]$grn"}else{"[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Связь с телефоном"} else {"Phone Link"})$grn"} else {"$(if ($PhoneSelected){"$sel[2]$red"}else{"$red[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Связь с телефоном"} else {"Phone Link"})$grn"})} else {"$red[2] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Связь с телефоном"} else {"Not Found | Phone Link"})$grn"})"
            Align-TextCenter "$(if($Help.HasAllUsers){$(if($Help.HasUser){"$(if ($HelpSelected){"$sel[3]$grn"}else{"[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Техническая поддержка"} else {"Contact Support"})$grn"} else {"$(if ($HelpSelected){"$sel[3]$red"}else{"$red[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Техническая поддержка"} else {"Contact Support"})$grn"})} else {"$red[3] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Техническая поддержка"} else {"Not Found | Contact Support"})$grn"})"
            Align-TextCenter "$(if($Feedback.HasAllUsers){$(if($Feedback.HasUser){"$(if ($FeedbackSelected){"$sel[4]$grn"}else{"[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Центр отзывов"} else {"Feedback Hub"})$grn"} else {"$(if ($FeedbackSelected){"$sel[4]$red"}else{"$red[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Центр отзывов"} else {"Feedback Hub"})$grn"})} else {"$red[4] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Центр отзывов"} else {"Not Found | Feedback Hub"})$grn"})"
            Align-TextCenter "$(if($Notepad.HasAllUsers){$(if($Notepad.HasUser){"$(if ($NotepadSelected){"$sel[5]$grn"}else{"[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Блокнот"} else {"Notepad"})$grn"} else {"$(if ($NotepadSelected){"$sel[5]$red"}else{"$red[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Блокнот"} else {"Notepad"})$grn"})} else {"$red[5] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Блокнот"} else {"Not Found | Notepad"})$grn"})"
            Align-TextCenter "$(if($Assist.HasAllUsers){$(if($Assist.HasUser){"$(if ($AssistSelected){"$sel[6]$grn"}else{"[6]"}) $(if($Menu_Lang -eq "ru-Ru"){"Быстрая помощь"} else {"Quick Assist"})$grn"} else {"$(if ($AssistSelected){"$sel[6]$red"}else{"$red[6]"}) $(if($Menu_Lang -eq "ru-Ru"){"Быстрая помощь"} else {"Quick Assist"})$grn"})} else {"$red[6] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Быстрая помощь"} else {"Not Found | Quick Assist"})$grn"})"
            Align-TextCenter "$(if($News.HasAllUsers){$(if($News.HasUser){"$(if ($NewsSelected){"$sel[7]$grn"}else{"[7]"}) $(if($Menu_Lang -eq "ru-Ru"){"Новости"} else {"News"})$grn"} else {"$(if ($NewsSelected){"$sel[7]$red"}else{"$red[7]"}) $(if($Menu_Lang -eq "ru-Ru"){"Новости"} else {"News"})$grn"})} else {"$red[7] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Новости"} else {"Not Found | News"})$grn"})"
            Align-TextCenter "$(if($Portal.HasAllUsers){$(if($Portal.HasUser){"$(if ($PortalSelected){"$sel[8]$grn"}else{"[8]"}) $(if($Menu_Lang -eq "ru-Ru"){"Портал смешанной реальности"} else {"Mixed Reality Portal"})$grn"} else {"$(if ($PortalSelected){"$sel[8]$red"}else{"$red[8]"}) $(if($Menu_Lang -eq "ru-Ru"){"Портал смешанной реальности"} else {"Mixed Reality Portal"})$grn"})} else {"$red[8] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Портал смешанной реальности"} else {"Not Found | Mixed Reality Portal"})$grn"})"
            Align-TextCenter "$sel[9]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Назад$grn"} else {"${sel}Back$grn"})"
            Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Изменить выбранные   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Режим полного удаления$grn"} else {"[Space] - Change selected   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Full removal mode$grn"})" -NewLine
            Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"Страница 2"} else {"Page 2"})"
            Center-Text "$grn<- [A]      [D] ->"


            do {
                $choice = [Console]::ReadKey($true).Key
                if($choice -eq "F1"){$PermanentMode = -not $PermanentMode ; Base_page_two} #Permanent mode
                if ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -and ($Weather.HasAllUsers)){$WeatherSelected = -not $WeatherSelected ; Base_page_two} #Weather
                if ((($choice -eq "D2") -or ($choice -eq "NumPad2")) -and ($Phone.HasAllUsers)){$PhoneSelected = -not $PhoneSelected ; Base_page_two} #Phone
                if ((($choice -eq "D3") -or ($choice -eq "NumPad3")) -and ($Help.HasAllUsers)){$HelpSelected = -not $HelpSelected ; Base_page_two} #Help
                if ((($choice -eq "D4") -or ($choice -eq "NumPad4")) -and ($Feedback.HasAllUsers)){$FeedbackSelected = -not $FeedbackSelected ; Base_page_two} #Feedback
                if ((($choice -eq "D5") -or ($choice -eq "NumPad5")) -and ($Notepad.HasAllUsers)){$NotepadSelected = -not $NotepadSelected ; Base_page_two} #Notepad
                if ((($choice -eq "D6") -or ($choice -eq "NumPad6")) -and ($Assist.HasAllUsers)){$AssistSelected = -not $AssistSelected ; Base_page_two} #Assist
                if ((($choice -eq "D7") -or ($choice -eq "NumPad7")) -and ($News.HasAllUsers)){$NewsSelected = -not $NewsSelected ; Base_page_two} #News
                if ((($choice -eq "D8") -or ($choice -eq "NumPad8")) -and ($Portal.HasAllUsers)){$PortalSelected = -not $PortalSelected ; Base_page_two} #Portal
                if ($choice -eq "Spacebar") {Removing -Page "base_page_2" }
                if (($choice -eq "D9") -or ($choice -eq "NumPad9") -or ($choice -eq "Escape")){Basic_programs}
                if (($choice -eq "A") -or ($choice -eq "LeftArrow")){Basic_programs}
                if (($choice -eq "D") -or ($choice -eq "RightArrow")){Base_page_three}
            } until ($choice -eq "D9")
        }
        #endregion

        #region Третья страница базовых программ
        function Base_page_three{
            


            $Getstarted = Test-AppxPackagePresence "Microsoft.Getstarted"
            $Mail = Test-AppxPackagePresence "Microsoft.windowscommunicationsapps"
            $People = Test-AppxPackagePresence "Microsoft.People"
            $3DViewer = Test-AppxPackagePresence "Microsoft.Microsoft3DViewer"
            $Maps = Test-AppxPackagePresence "Microsoft.WindowsMaps"
            $ZuneVideo = Test-AppxPackagePresence "Microsoft.ZuneVideo"



            Draw-Banner
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
            Align-TextCenter "$(if($Getstarted.HasAllUsers){$(if($Getstarted.HasUser){"$(if ($GetstartedSelected){"$sel[1]$grn"}else{"[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Советы"} else {"Tips"})$grn"} else {"$(if ($GetstartedSelected){"$sel[1]$red"}else{"$red[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Советы"} else {"Tips"})$grn"})} else {"$red[1] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Советы"} else {"Not Found | Tips"})$grn"})"
            Align-TextCenter "$(if($Mail.HasAllUsers){$(if($Mail.HasUser){"$(if ($MailSelected){"$sel[2]$grn"}else{"[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Почта"} else {"Mail"})$grn"} else {"$(if ($MailSelected){"$sel[2]$red"}else{"$red[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Почта"} else {"Mail"})$grn"})} else {"$red[2] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Почта"} else {"Not Found | Mail"})$grn"})"
            Align-TextCenter "$(if($People.HasAllUsers){$(if($People.HasUser){"$(if ($PeopleSelected){"$sel[3]$grn"}else{"[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Люди"} else {"People"})$grn"} else {"$(if ($PeopleSelected){"$sel[3]$red"}else{"$red[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Люди"} else {"People"})$grn"})} else {"$red[3] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Люди"} else {"Not Found | People"})$grn"})"
            Align-TextCenter "$(if($3DViewer.HasAllUsers){$(if($3DViewer.HasUser){"$(if ($3DViewerSelected){"$sel[4]$grn"}else{"[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Средство 3D-просмотра"} else {"3D Viewer"})$grn"} else {"$(if ($3DViewerSelected){"$sel[4]$red"}else{"$red[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Средство 3D-просмотра"} else {"3D Viewer"})$grn"})} else {"$red[4] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Средство 3D-просмотра"} else {"Not Found | 3D Viewer"})$grn"})"
            Align-TextCenter "$(if($Maps.HasAllUsers){$(if($Maps.HasUser){"$(if ($MapsSelected){"$sel[5]$grn"}else{"[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Карты"} else {"Maps"})$grn"} else {"$(if ($MapsSelected){"$sel[5]$red"}else{"$red[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Карты"} else {"Maps"})$grn"})} else {"$red[5] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Карты"} else {"Not Found | Maps"})$grn"})"
            Align-TextCenter "$(if($ZuneVideo.HasAllUsers){$(if($ZuneVideo.HasUser){"$(if ($ZuneVideoSelected){"$sel[6]$grn"}else{"[6]"}) $(if($Menu_Lang -eq "ru-Ru"){"Встроенный видеоплеер"} else {"Default Video Player"}) (!)$grn"} else {"$(if ($ZuneVideoSelected){"$sel[6]$red"}else{"$red[6]"}) $(if($Menu_Lang -eq "ru-Ru"){"Встроенный видеоплеер"} else {"Default Video Player"}) (!)$grn"})} else {"$red[6] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Встроенный видеоплеер"} else {"Not Found | Default Video Player"}) (!)$grn"})"
            Write-Host "`n`n`n"
            Align-TextCenter "$sel[9]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Назад$grn"} else {"${sel}Back$grn"})"
            Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Изменить выбранные   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Режим полного удаления$grn"} else {"[Space] - Change selected   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Full removal mode$grn"})" -NewLine
            Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"Страница 3"} else {"Page 3"})"
            Center-Text "$grn<- [A]            "



            do {
                $choice = [Console]::ReadKey($true).Key
                if($choice -eq "F1"){$PermanentMode = -not $PermanentMode ; Base_page_three} #Permanent mode
                if ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -and ($Getstarted.HasAllUsers)){$GetstartedSelected = -not $GetstartedSelected ; Base_page_three} #Getstarted
                if ((($choice -eq "D2") -or ($choice -eq "NumPad2")) -and ($Mail.HasAllUsers)){$MailSelected = -not $MailSelected ; Base_page_three} #Mail
                if ((($choice -eq "D3") -or ($choice -eq "NumPad3")) -and ($People.HasAllUsers)){$PeopleSelected = -not $PeopleSelected ; Base_page_three} #People
                if ((($choice -eq "D4") -or ($choice -eq "NumPad4")) -and ($3DViewer.HasAllUsers)){$3DViewerSelected = -not $3DViewerSelected ; Base_page_three} #3DViewer
                if ((($choice -eq "D5") -or ($choice -eq "NumPad5")) -and ($Maps.HasAllUsers)){$MapsSelected = -not $MapsSelected ; Base_page_three} #Maps
                if ((($choice -eq "D6") -or ($choice -eq "NumPad6")) -and ($ZuneVideo.HasAllUsers)){$ZuneVideoSelected = -not $ZuneVideoSelected ; Base_page_three} #ZuneVideo
                if ($choice -eq "Spacebar") {Removing -Page "base_page_3" }
                if (($choice -eq "D9") -or ($choice -eq "NumPad9") -or ($choice -eq "Escape")){Base_page_two}
                if (($choice -eq "A") -or ($choice -eq "LeftArrow")){Base_page_two}
            } until ($choice -eq "D9")
        }
        #endregion



        $Calc = Test-AppxPackagePresence "Microsoft.WindowsCalculator"
        $ZuneMusic = Test-AppxPackagePresence "Microsoft.ZuneMusic"
        $Photo = Test-AppxPackagePresence "Microsoft.Windows.Photos"
        $Sketch = Test-AppxPackagePresence "Microsoft.ScreenSketch"
        $Alarms = Test-AppxPackagePresence "Microsoft.WindowsAlarms"
        $Paint3d = Test-AppxPackagePresence -Names "Microsoft.Paint", "Microsoft.MSPaint"
        $Recorder = Test-AppxPackagePresence "Microsoft.WindowsSoundRecorder"
        $Camera = Test-AppxPackagePresence "Microsoft.WindowsCamera"



        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
        Align-TextCenter "$(if($Calc.HasAllUsers){$(if($Calc.HasUser){"$(if ($CalcSelected){"$sel[1]$grn"}else{"[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Калькулятор"} else {"Calculator"}) (!)$grn"} else {"$(if ($CalcSelected){"$sel[1]$red"}else{"$red[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Калькулятор"} else {"Calculator"}) (!)$grn"})} else {"$red[1] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Калькулятор"} else {"Not Found | Calculator"}) (!)$grn"})"
        Align-TextCenter "$(if($ZuneMusic.HasAllUsers){$(if($ZuneMusic.HasUser){"$(if ($ZuneMusicSelected){"$sel[2]$grn"}else{"[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Встроенный музыкальный плеер"} else {"Default Music Player"})$grn"} else {"$(if ($ZuneMusicSelected){"$sel[2]$red"}else{"$red[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Встроенный музыкальный плеер"} else {"Default Music Player"})$grn"})} else {"$red[2] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Встроенный музыкальный плеер"} else {"Not Found | Default Music Player"})$grn"})"
        Align-TextCenter "$(if($Photo.HasAllUsers){$(if($Photo.HasUser){"$(if ($PhotoSelected){"$sel[3]$grn"}else{"[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Фотографии"} else {"Photo"})$grn"} else {"$(if ($PhotoSelected){"$sel[3]$red"}else{"$red[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Фотографии"} else {"Photo"})$grn"})} else {"$red[3] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Фотографии"} else {"Not Found | Photo"})$grn"})"
        Align-TextCenter "$(if($Sketch.HasAllUsers){$(if($Sketch.HasUser){"$(if ($SketchSelected){"$sel[4]$grn"}else{"[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Набросок на фрагменте экрана"} else {"Snip & Sketch"})$grn"} else {"$(if ($SketchSelected){"$sel[4]$red"}else{"$red[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Набросок на фрагменте экрана"} else {"Snip & Sketch"})$grn"})} else {"$red[4] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Набросок на фрагменте экрана"} else {"Not Found | Snip & Sketch"})$grn"})"
        Align-TextCenter "$(if($Alarms.HasAllUsers){$(if($Alarms.HasUser){"$(if ($AlarmsSelected){"$sel[5]$grn"}else{"[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Часы"} else {"Alarms"})$grn"} else {"$(if ($AlarmsSelected){"$sel[5]$red"}else{"$red[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Часы"} else {"Alarms"})$grn"})} else {"$red[5] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Часы"} else {"Not Found | Alarms"})$grn"})"
        Align-TextCenter "$(if($Paint3d.HasAllUsers){$(if($Paint3d.HasUser){"$(if ($Paint3dSelected){"$sel[6]$grn"}else{"[6]"}) Paint 3D$grn"} else {"$(if ($Paint3dSelected){"$sel[6]$red"}else{"$red[6]"}) Paint 3D$grn"})} else {"$red[6] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Paint 3D"} else {"Not Found | Paint 3D"})$grn"})"
        Align-TextCenter "$(if($Recorder.HasAllUsers){$(if($Recorder.HasUser){"$(if ($RecorderSelected){"$sel[7]$grn"}else{"[7]"}) $(if($Menu_Lang -eq "ru-Ru"){"Запись голоса"} else {"Recorder"})$grn"} else {"$(if ($RecorderSelected){"$sel[7]$red"}else{"$red[7]"}) $(if($Menu_Lang -eq "ru-Ru"){"Запись голоса"} else {"Recorder"})$grn"})} else {"$red[7] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Запись голоса"} else {"Not Found | Recorder"})$grn"})"
        Align-TextCenter "$(if($Camera.HasAllUsers){$(if($Camera.HasUser){"$(if ($CameraSelected){"$sel[8]$grn"}else{"[8]"}) $(if($Menu_Lang -eq "ru-Ru"){"Камера"} else {"Camera"})$grn"} else {"$(if ($CameraSelected){"$sel[8]$red"}else{"$red[8]"}) $(if($Menu_Lang -eq "ru-Ru"){"Камера"} else {"Camera"})$grn"})} else {"$red[8] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Камера"} else {"Not Found | Camera"})$grn"})"
        Align-TextCenter "$sel[9]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Выход в меню$grn"} else {"${sel}Back to menu$grn"})" -NewLine
        Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Изменить выбранные   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Режим полного удаления$grn"} else {"[Space] - Change selected   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Full removal mode$grn"})" -NewLine
        Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"Страница 1"} else {"Page 1"})"
        Center-Text "$grn            [D] ->"



        do {
            $choice = [Console]::ReadKey($true).Key
            if($choice -eq "F1"){$PermanentMode = -not $PermanentMode ; Basic_programs} #Permanent mode
            if ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -and ($Calc.HasAllUsers)){$CalcSelected = -not $CalcSelected ; Basic_programs} #Calc
            if ((($choice -eq "D2") -or ($choice -eq "NumPad2")) -and ($ZuneMusic.HasAllUsers)){$ZuneMusicSelected = -not $ZuneMusicSelected ; Basic_programs} #ZuneMusic
            if ((($choice -eq "D3") -or ($choice -eq "NumPad3")) -and ($Photo.HasAllUsers)){$PhotoSelected = -not $PhotoSelected ; Basic_programs} #Photo
            if ((($choice -eq "D4") -or ($choice -eq "NumPad4")) -and ($Sketch.HasAllUsers)){$SketchSelected = -not $SketchSelected ; Basic_programs} #Sketch
            if ((($choice -eq "D5") -or ($choice -eq "NumPad5")) -and ($Alarms.HasAllUsers)){$AlarmsSelected = -not $AlarmsSelected ; Basic_programs} #Alarms
            if ((($choice -eq "D6") -or ($choice -eq "NumPad6")) -and ($Paint3d.HasAllUsers)){$Paint3dSelected = -not $Paint3dSelected ; Basic_programs} #Paint3d
            if ((($choice -eq "D7") -or ($choice -eq "NumPad7")) -and ($Recorder.HasAllUsers)){$RecorderSelected = -not $RecorderSelected ; Basic_programs} #Recorder
            if ((($choice -eq "D8") -or ($choice -eq "NumPad8")) -and ($Camera.HasAllUsers)){$CameraSelected = -not $CameraSelected ; Basic_programs} #Camera
            if ($choice -eq "Spacebar") {Removing -Page "base_page_1" }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9") -or ($choice -eq "Escape")){Action_choose}
            if (($choice -eq "D") -or ($choice -eq "RightArrow")){Base_page_two}
        } until ($choice -eq "D9")




    }
    #endregion

    #region Вторая страница
    function Page_two{
        

        
        $OfficeHub = Test-AppxPackagePresence "Microsoft.MicrosoftOfficeHub"
        $Solitaire = Test-AppxPackagePresence "Microsoft.MicrosoftSolitaireCollection"
        $Clipchamp = Test-AppxPackagePresence "Clipchamp.Clipchamp"
        $Outlook = Test-AppxPackagePresence "Microsoft.OutlookForWindows"
        $Teams = Test-AppxPackagePresence "MSTeams"
        $Todo = Test-AppxPackagePresence "Microsoft.Todos"
        $DevHome = Test-AppxPackagePresence "Microsoft.Windows.DevHome"
        $PowerAutomate = Test-AppxPackagePresence "Microsoft.PowerAutomateDesktop"


        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
        Align-TextCenter "$(if($OfficeHub.HasAllUsers){$(if($OfficeHub.HasUser){"$(if ($OfficeHubSelected){"$sel[1]$grn"}else{"[1]"}) Office Hub$grn"} else {"$(if ($OfficeHubSelected){"$sel[1]$red"}else{"$red[1]"}) Office Hub$grn"})} else {"$red[1] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Office Hub"} else {"Not Found | Office Hub"})$grn"})"
        Align-TextCenter "$(if($Solitaire.HasAllUsers){$(if($Solitaire.HasUser){"$(if ($SolitaireSelected){"$sel[2]$grn"}else{"[2]"}) Solitaire & Casual Games$grn"} else {"$(if ($SolitaireSelected){"$sel[2]$red"}else{"$red[2]"}) Solitaire & Casual Games$grn"})} else {"$red[2] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Solitaire & Casual Games"} else {"Not Found | Solitaire & Casual Games"})$grn"})"
        Align-TextCenter "$(if($Clipchamp.HasAllUsers){$(if($Clipchamp.HasUser){"$(if ($ClipchampSelected){"$sel[3]$grn"}else{"[3]"}) Clipchamp"} else {"$(if ($ClipchampSelected){"$sel[3]$red"}else{"$red[3]"}) Clipchamp$grn"})} else {"$red[3] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Clipchamp"} else {"Not Found | Clipchamp"})$grn"})"
        Align-TextCenter "$(if($Outlook.HasAllUsers)  {$(if($Outlook.HasUser){"$(if ($OutlookSelected){"$sel[4]$grn"}else{"[4]"}) Outlook"} else {"$(if ($OutlookSelected){"$sel[4]$red"}else{"$red[4]"}) Outlook$grn"})} else {"$red[4] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Outlook"} else {"Not Found | Outlook"})$grn"})"
        Align-TextCenter "$(if($Teams.HasAllUsers){$(if($Teams.HasUser){"$(if ($TeamsSelected){"$sel[5]$grn"}else{"[5]"}) Teams"} else {"$(if ($TeamsSelected){"$sel[5]$red"}else{"$red[5]"}) Teams$grn"})} else {"$red[5] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Teams"} else {"Not Found | Teams"})$grn"})"
        Align-TextCenter "$(if($Todo.HasAllUsers){$(if($Todo.HasUser){"$(if ($TodoSelected){"$sel[6]$grn"}else{"[6]"}) To do"} else {"$(if ($TodoSelected){"$sel[6]$red"}else{"$red[6]"}) To do$grn"})} else {"$red[6] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | To do"} else {"Not Found | To do"})$grn"})"
        Align-TextCenter "$(if($DevHome.HasAllUsers){$(if($DevHome.HasUser){"$(if ($DevHomeSelected){"$sel[7]$grn"}else{"[7]"}) Dev Home"} else {"$(if ($DevHomeSelected){"$sel[7]$red"}else{"$red[7]"}) Dev Home$grn"})} else {"$red[7] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Dev Home"} else {"Not Found | Dev Home"})$grn"})"
        Align-TextCenter "$(if($PowerAutomate.HasAllUsers){$(if($PowerAutomate.HasUser){"$(if ($PowerAutomateSelected){"$sel[8]$grn"}else{"[8]"}) Power Automate"} else {"$(if ($PowerAutomateSelected){"$sel[8]$grn"}else{"$red[8]"}) Power Automate$grn"})} else {"$red[8] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Power Automate"} else {"Not Found | Power Automate"})$grn"})"
        Align-TextCenter "$sel[9]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Назад$grn"} else {"${sel}Back$grn"})"
        Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Изменить выбранные   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Режим полного удаления$grn"} else {"[Space] - Change selected   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Full removal mode$grn"})" -NewLine
        Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"Страница 2"} else {"Page 2"})"
        Center-Text "$grn<- [A]            "



        do {
            $choice = [Console]::ReadKey($true).Key
            if($choice -eq "F1"){$PermanentMode = -not $PermanentMode ; Page_two} #Permanent mode
            if ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -and ($OfficeHub.HasAllUsers)){$OfficeHubSelected = -not $OfficeHubSelected ; Page_two} #Office Hub
            if ((($choice -eq "D2") -or ($choice -eq "NumPad2")) -and ($Solitaire.HasAllUsers)){$SolitaireSelected = -not $SolitaireSelected ; Page_two} #Solitaire
            if ((($choice -eq "D3") -or ($choice -eq "NumPad3")) -and ($Clipchamp.HasAllUsers)){$ClipchampSelected = -not $ClipchampSelected ; Page_two} #Clipchamp
            if ((($choice -eq "D4") -or ($choice -eq "NumPad4")) -and ($Outlook.HasAllUsers)){$OutlookSelected = -not $OutlookSelected ; Page_two} #Outlook
            if ((($choice -eq "D5") -or ($choice -eq "NumPad5")) -and ($Teams.HasAllUsers)){$TeamsSelected = -not $TeamsSelected ; Page_two} #Teams
            if ((($choice -eq "D6") -or ($choice -eq "NumPad6")) -and ($Todo.HasAllUsers)){$TodoSelected = -not $TodoSelected ; Page_two} #Todo
            if ((($choice -eq "D7") -or ($choice -eq "NumPad7")) -and ($DevHome.HasAllUsers)){$DevHomeSelected = -not $DevHomeSelected ; Page_two} #DevHome
            if ((($choice -eq "D8") -or ($choice -eq "NumPad8")) -and ($PowerAutomate.HasAllUsers)){$PowerAutomateSelected = -not $PowerAutomateSelected ; Page_two} #PowerAutomate
            if ($choice -eq "Spacebar") {Removing -Page "page_2" }
            if (($choice -eq "A") -or ($choice -eq "LeftArrow")){Action_choose}
            if (($choice -eq "D9") -or ($choice -eq "NumPad9") -or ($choice -eq "Escape")){Action_choose}
        } until ($choice -eq "D9")
    }
    #endregion

    #region Главная страница


    $OneDriveSetup = $false
    if((Test-Path "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe") -or (Test-Path "C:\Program Files\Microsoft OneDrive\OneDrive.exe")){$OneDrive = $true}
    if((Test-Path "C:\Windows\SysWOW64\OneDriveSetup.exe") -or (Test-Path "C:\Windows\System32\OneDriveSetup.exe")){$OneDriveSetup = $true}
    $Cortana = Test-AppxPackagePresence "Microsoft.549981C3F5F10"
    $OneNote = Test-AppxPackagePresence "Microsoft.Office.OneNote"
    $Skype = Test-AppxPackagePresence "Microsoft.SkypeApp"
    $Store = Test-AppxPackagePresence "Microsoft.WindowsStore"
    $Notes = Test-AppxPackagePresence "Microsoft.MicrosoftStickyNotes"
    $Xbox = Test-AppxPackagePresence -Names "Microsoft.XboxGameOverlay", "Microsoft.XboxApp", "Microsoft.Xbox.TCUI", "Microsoft.XboxSpeechToTextOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider"



    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
    Align-TextCenter "[1] $(if($Menu_Lang -eq "ru-Ru"){"Базовые приложения системы\"} else {"Basic system applications\"})"
    Align-TextCenter "$(if($OneDriveSetup){$(if($OneDrive){"$(if ($OneDriveSelected){"$sel[2]$grn"}else{"[2]"}) OneDrive"} else {"$(if ($OneDriveSelected){"$sel[2]$red"}else{"$red[2]"}) OneDrive$grn""})}else{"$red[2] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | OneDrive"} else {"Not Found | OneDrive"})$grn"})"
    Align-TextCenter "$(if($Cortana.HasAllUsers){$(if($Cortana.HasUser){"$(if ($CortanaSelected){"$sel[3]$grn"}else{"[3]"}) Cortana$grn"} else {"$(if ($CortanaSelected){"$sel[3]$red"}else{"$red[3]"}) Cortana$grn"})} else {"$red[3] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Cortana"} else {"Not Found | Cortana"})$grn"})"
    Align-TextCenter "$(if($OneNote.HasAllUsers){$(if($OneNote.HasUser){"$(if ($OneNoteSelected){"$sel[4]$grn"}else{"[4]"}) OneNote$grn"} else {"$(if ($OneNoteSelected){"$sel[4]$red"}else{"$red[4]"}) OneNote$grn"})} else {"$red[4] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | OneNote"} else {"Not Found | OneNote"})$grn"})"
    Align-TextCenter "$(if($Skype.HasAllUsers){$(if($Skype.HasUser){"$(if ($SkypeSelected){"$sel[5]$grn"}else{"[5]"}) Skype$grn"} else {"$(if ($SkypeSelected){"$sel[5]$red"}else{"$red[5]"}) Skype$grn"})} else {"$red[5] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Skype"} else {"Not Found | Skype"})$grn"})"
    Align-TextCenter "$(if($Store.HasAllUsers){$(if($Store.HasUser){"$(if ($StoreSelected){"$sel[6]$grn"}else{"[6]"}) Microsoft Store$grn"} else {"$(if ($StoreSelected){"$sel[6]$red"}else{"$red[6]"}) Microsoft Store$grn"})} else {"$red[6] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Microsoft Store"} else {"Not Found | Microsoft Store"})$grn"})"
    Align-TextCenter "$(if($Notes.HasAllUsers){$(if($Notes.HasUser){"$(if ($NotesSelected){"$sel[7]$grn"}else{"[7]"}) $(if($Menu_Lang -eq "ru-Ru"){"Записки"} else {"Sticky Notes"})$grn"} else {"$(if ($NotesSelected){"$sel[7]$red"}else{"$red[7]"}) $(if($Menu_Lang -eq "ru-Ru"){"Записки"} else {"Sticky Notes"})$grn"})} else {"$red[7] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Записки"} else {"Not Found | Sticky Notes"})$grn"})"
    Align-TextCenter "$(if($Xbox.HasAllUsers){$(if($Xbox.HasUser){"$(if ($XboxSelected){"$sel[8]$grn"}else{"[8]"}) Xbox$grn"} else {"$(if ($XboxSelected){"$sel[8]$red"}else{"$red[8]"}) Xbox$grn"})} else {"$red[8] $(if($Menu_Lang -eq "ru-Ru"){"Не найдено | Xbox"} else {"Not Found | Xbox"})$grn"})"
    Align-TextCenter "$sel[9]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Выход в меню$grn"} else {"${sel}Back to menu$grn"})" -NewLine
    Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Изменить выбранные   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Режим полного удаления$grn"} else {"[Space] - Change selected   |   $(if ($PermanentMode){"$selred[F1]"}else{"[F1]"}) Full removal mode$grn"})" -NewLine
    Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"Страница 1"} else {"Page 1"})"
    Center-Text "$grn            [D] ->"



    do {
        $choice = [Console]::ReadKey($true).Key
        if($choice -eq "F1"){$PermanentMode = -not $PermanentMode ; Action_choose} #Permanent mode
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){Basic_programs}
        if ((($choice -eq "D2") -or ($choice -eq "NumPad2")) -and ($OneDriveSetup)){$OneDriveSelected = -not $OneDriveSelected ; Action_choose} #OneDrive
        if ((($choice -eq "D3") -or ($choice -eq "NumPad3")) -and ($Cortana.HasAllUsers)){$CortanaSelected = -not $CortanaSelected ; Action_choose} #Cortana
        if ((($choice -eq "D4") -or ($choice -eq "NumPad4")) -and ($OneNote.HasAllUsers)){$OneNoteSelected = -not $OneNoteSelected ; Action_choose} #OneNote
        if ((($choice -eq "D5") -or ($choice -eq "NumPad5")) -and ($Skype.HasAllUsers)){$SkypeSelected = -not $SkypeSelected ; Action_choose} #Skype
        if ((($choice -eq "D6") -or ($choice -eq "NumPad6")) -and ($Store.HasAllUsers)){$StoreSelected = -not $StoreSelected ; Action_choose} #Microsoft Store
        if ((($choice -eq "D7") -or ($choice -eq "NumPad7")) -and ($Notes.HasAllUsers)){$NotesSelected = -not $NotesSelected ; Action_choose} #Sticky Notes
        if ((($choice -eq "D8") -or ($choice -eq "NumPad8")) -and ($Xbox.HasAllUsers)){$XboxSelected = -not $XboxSelected ; Action_choose} #XboxApp
        if ($choice -eq "Spacebar") {Removing -Page "page_1" }
        if (($choice -eq "D9") -or ($choice -eq "NumPad9") -or ($choice -eq "Escape")){Goto-main}
        if (($choice -eq "D") -or ($choice -eq "RightArrow")){Page_two}
    } until ($choice -eq "D9")
    #endregion
}

#endregion

Action_choose
