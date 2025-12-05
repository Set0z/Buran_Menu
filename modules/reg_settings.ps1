#region Объявление переменных
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Конфигурация реестра 🛠️"} else {$host.ui.RawUI.WindowTitle = "Registry configuration 🛠️"})
$scriptDir = $PSScriptRoot
$uiLang = (Get-Culture).Name 
$Menu_Lang = $env:BURAN_lang
$win_ver = (Get-WmiObject Win32_OperatingSystem).Caption
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

if ($PSScriptRoot -eq "") {
    Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking
} else {
    $scriptDir = $PSScriptRoot
    Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking
}

if($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag") -like "False"){
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
    $needrestartexp = 1
}
if ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null){
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -PropertyType String
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Value Show
}

#region Объявление цветов
$grn = "$([char]27)[48;5;0;38;5;2m"   # черный фон, зеленый текст
$purp = "$([char]27)[48;5;0;38;5;13m"   # черный фон, фиолетовый текст
$red = "$([char]27)[48;5;0;38;5;1m"   # чёрный фон, красный текст

$sel = "$([char]27)[48;5;2;38;5;0m"   # зелёный фон, черный текст
$selred = "$([char]27)[48;5;1;38;5;0m"   # красный фон, черный текст
$selpurp = "$([char]27)[48;5;13;38;5;0m"   # фиолетовый фон, черный текст
#endregion

#endregion

#region Функции проверки параметров реестра
function Check-RegistryParameter-Arrow{
    if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -ErrorAction SilentlyContinue){
        return "Disable"
    } else {
        return "Enable"
    }
}

function Check-RegistryParameter-ThisPC{
    $valueThisPS = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
    if ($null -eq $valueThisPS){
        return "Enable"
    }
    if ($valueThisPS = "1"){
        return "Disable"
    }
}

function Check-RegistryParameter-CPanel{
    if( $(Test-Path -Path "HKCU:\Software\Classes\CLSID") -Like "False" -or $(Test-Path -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}") -Like "False" -or $(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null -or $((Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree")."System.IsPinnedToNameSpaceTree") -eq 0) {return "Enable"}
    if ($((Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree")."System.IsPinnedToNameSpaceTree")-ne 0) {return "Disable"}
}

function Check-RegistryParameter-Trash{
    if( $(Test-Path -Path "HKCU:\Software\Classes\CLSID") -Like "False" -or $(Test-Path -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}") -Like "False" -or $(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null -or $((Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree")."System.IsPinnedToNameSpaceTree") -eq 0) {return "Enable"}
    if ($((Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree")."System.IsPinnedToNameSpaceTree")-ne 0) {return "Disable"}
}

function Check-RegistryParameter-QuickAccess{
    if (($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -ErrorAction SilentlyContinue) -eq $null )) {return "Enable"}
    if (($((Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent")."ShowFrequent") -eq 1)) {return "Enable"}
    if ($((Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent")."ShowFrequent") -ne 1) {return "Disable"}
}

function Check-RegistryParameter-BingSearch{
    if( ($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled")."BingSearchEnabled" -eq 1)) {return "Enable"}
    if( $(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled")."BingSearchEnabled" -eq 0) {return "Disable"}
}

function Check-RegistryParameter-OneDrive {
    try {
        $regKey = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey("CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}")

        if ($regKey -eq $null) {
            return "Enable"
        }
        $isPinned = $regKey.GetValue("System.IsPinnedToNameSpaceTree", $null)

        if ($isPinned -eq $null -or $isPinned -eq 1) {
            return "Enable"
        } elseif ($isPinned -eq 0) {
            return "Disable"
        } else {
            return "Unknown"
        }
    } catch {
        return "Unknown"
    }
}

function Check-RegistryParameter-Network{
    if(($(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree")."System.IsPinnedToNameSpaceTree" -eq 1)) {return "Enable"}
    if($(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree")."System.IsPinnedToNameSpaceTree" -eq 0) {return "Disable"}
}

function Check-RegistryParameter-3dObjects{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-Pictures{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-Videos{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-Downloads{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-Music{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-Documents{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-Desktop{
    if(($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag") -like "False") -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Show")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") {return "Disable"}
}

function Check-RegistryParameter-HideAll{
    if(($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") -and ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") -and ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") -and ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") -and ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") -and ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide") -and ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy")."ThisPCPolicy" -eq "Hide")) {return "Disable"} else {return "Enable"}
}

function Check-RegistryParameter-Permanently-Delete {
    try {
        $regKey = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey("AllFilesystemObjects\shell\Windows.PermanentDelete")
        if ($regKey -ne $null) {
            return "Disable"
        } else {
            return "Enable"
        }
    } catch {
        return "Unknown"
    }
}

function Check-RegistryParameter-Win11Classic{
    if(($(Test-Path -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}") -like "False") -or ($(Test-Path -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32") -like "False") -or ($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)")."(default)" -ne "")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)")."(default)" -eq "") {return "Disable"}
}

function Check-RegistryParameter-DisallowShaking{
    if(($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -ErrorAction SilentlyContinue) -eq $null) -or ($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking")."DisallowShaking" -eq "0")) {return "Enable"}
    if($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking")."DisallowShaking" -eq "1") {return "Disable"}
}

function Check-RegistryParameter-StickyKeys{
    if(($(Get-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags")."Flags") -eq 510){return "Enable"} else {return "Disable"}
}

function Check-RegistryParameter-SystemUsesLightTheme{
    if(($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme")."SystemUsesLightTheme") -eq 1){return "Enable"} else {return "Disable"}
}

function Check-RegistryParameter-AppsUseLightTheme{
    if(($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme")."AppsUseLightTheme") -eq 1){return "Enable"} else {return "Disable"}
}

function Check-RegistryParameter-ContentDeliveryManager{
    if((($(Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -ErrorAction SilentlyContinue)."ScoobeSystemSettingEnabled") -eq 1) -or (($(Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -ErrorAction SilentlyContinue)."SubscribedContent-310093Enabled") -eq 1) -or (($(Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -ErrorAction SilentlyContinue)."SubscribedContent-338389Enabled") -eq 1)){return "Enable"} else {return "Disable"}
}
#endregion

#region Меню
function Action-choose {
    
    #region Скрытие папок из "Этот компьютер"
    function this-pc{
    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Select action"})" -NewLine
    Align-TextCenter "$(if($(Check-RegistryParameter-HideAll) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-HideAll)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-HideAll) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mВсе Папки$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mAll Folders$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Videos) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Videos)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Videos) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mВидео$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mVideos$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Documents) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Documents)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Documents) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mДокументы$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mDocuments$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Downloads) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Downloads)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Downloads) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mЗагрузки$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mDownloads$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Pictures) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Pictures)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Pictures) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mИзображения$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mPictures$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Music) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Music)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Music) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mМузыка$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mMusic$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-3dObjects) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-3dObjects)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-3dObjects) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mОбъемные объекты$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4m3d Objects$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Desktop) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Desktop)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Desktop) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть $([char]27)[48;5;0m$([char]27)[38;5;2;4mРабочий стол$([char]27)[24m в «Этот Компьютер»"} else {"Hide $([char]27)[48;5;0m$([char]27)[38;5;2;4mDesktop$([char]27)[24m in «This PC»"})"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"
    do {
    $choice = [Console]::ReadKey($true).Key            #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        $regstate = Check-RegistryParameter-HideAll

        if ($regstate -eq "Enable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Value Hide

            if($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag") -like "False"){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
            }
            if ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null){
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -PropertyType String
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Value Hide


            if($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag") -like "False"){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
                $needrestartexp = 1
            }
            if ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null){
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -PropertyType String
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            if ($needrestartexp -eq 1){
                Stop-Process -Name explorer -Force
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                Write-Host ""

                Start-Sleep -Seconds 3
                if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
                # Если процесс не найден, запускаем explorer.exe
                Start-Process "explorer.exe"
                }

                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выполнено!"} else {"Done!"})"
                Write-Host ""
                $needrestartexp = 0
                pause
                this-pc
            this-pc
        }




            this-pc
        }
        if ($regstate -eq "Disable") {
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Value Show
           this-pc
        }
    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
        $regstate = Check-RegistryParameter-Videos

        if ($regstate -eq "Enable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
        $regstate = Check-RegistryParameter-Documents

        if ($regstate -eq "Enable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
        $regstate = Check-RegistryParameter-Downloads

        if ($regstate -eq "Enable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
        $regstate = Check-RegistryParameter-Pictures

        if ($regstate -eq "Enable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
        $regstate = Check-RegistryParameter-Music

        if ($regstate -eq "Enable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
        $regstate = Check-RegistryParameter-3dObjects

        if ($regstate -eq "Enable") {
            if($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag") -like "False"){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag"
                $needrestartexp = 1
            }
            if ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null){
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -PropertyType String
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            if ($needrestartexp -eq 1){
                Stop-Process -Name explorer -Force
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                Write-Host ""

                Start-Sleep -Seconds 3
                if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
                # Если процесс не найден, запускаем explorer.exe
                Start-Process "explorer.exe"
                }

                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выполнено!"} else {"Done!"})"
                Write-Host ""
                $needrestartexp = 0
                pause
                this-pc
            }
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
        $regstate = Check-RegistryParameter-Desktop

        if ($regstate -eq "Enable") {
            if($(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag") -like "False"){
                New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag"
            }
            if ($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue) -eq $null){
                New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -PropertyType String
            }
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Value Hide
            this-pc
        }
        if ($regstate -eq "Disable") {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Value Show
            this-pc
        }
    }
    if (($choice -eq "D9") -or ($choice -eq "NumPad9")){ Action-choose }
    if ($choice -eq "Escape"){ Action-choose }
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or (($choice -eq "D7") -or ($choice -eq "NumPad7")) -or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
    }
    #endregion

    #region Вторая страница
        function page-two {
            Draw-Banner
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Select action"})" -NewLine
            Align-TextCenter "$(if($(Check-RegistryParameter-DisallowShaking) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-DisallowShaking)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-DisallowShaking) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Отключить «Встряхнуть чтобы свернуть»"} else {"Turn off «Shake To Minimize»"})"
            Align-TextCenter "$(if($(Check-RegistryParameter-StickyKeys) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-StickyKeys)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-StickyKeys) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Отключить залипание клавиш"} else {"Turn off Sticky Keys"})"
            Align-TextCenter "$(if($(Check-RegistryParameter-ContentDeliveryManager) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-ContentDeliveryManager)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-ContentDeliveryManager) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Отключить Экран завершение настройки"} else {"Turn off Setup completion screen"})"
            Align-TextCenter "$(if($(Check-RegistryParameter-Arrow) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Arrow)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-Arrow) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть стрелки из ярлыков"} else {"Hide Arrows From Shortcuts"})"
            Align-TextCenter "$(if($(Check-RegistryParameter-CPanel) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-CPanel)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-CPanel) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Закрепить «Панель управления» на панели проводника"} else {"Pin Control Panel to the File Explorer navigation panel"})"
            Align-TextCenter "$(if($(Check-RegistryParameter-Trash) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Trash)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Trash) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Закрепить «Корзину» на панели проводника"} else {"Pin Recycle Bin to the File Explorer navigation panel"})"
            Align-TextCenter "$(if($(Check-RegistryParameter-Permanently-Delete) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Permanently-Delete)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-Permanently-Delete) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Добавить «Удалить навсегда» в контекстное меню"} else {"Add «Permanently delete» to the Context Menu"})"
            Write-Host "`n"
            Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"
            Write-Host "`n"
            Center-Text "$([char]27)[48;5;0m$([char]27)[38;5;10m$(if($Menu_Lang -eq "ru-Ru"){"Страница 2"} else {"Page 2"})"
            Center-Text "$([char]27)[48;5;0m$([char]27)[38;5;10m<- [A]            "
            do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                $regstate = Check-RegistryParameter-DisallowShaking

                if($regstate -eq "Enable"){
                    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking" -PropertyType DWord -Value 1
                    page-two
                }

                if($regstate -eq "Disable"){
                    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisallowShaking"
                    page-two
                }
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){$regstate = Check-RegistryParameter-StickyKeys ; if ($regstate -eq "Enable"){Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506" ; page-two} ; if ($regstate -eq "Disable"){Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "510" ; page-two}}
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                $regstate = Check-RegistryParameter-ContentDeliveryManager
                if ($regstate -eq "Enable"){
                    if(-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement")){
                        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Force | Out-Null
                    }
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 0
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
                }
                if ($regstate -eq "Disable"){
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Type DWord -Value 1
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 1
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 1
                }
                page-two
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if (-not (Test-Path -Path $registryPath)) {
                    New-Item -Path $registryPath -Force | Out-Null
                }
                $regstate = Check-RegistryParameter-Arrow
                if ($regstate -eq "Disable") {
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Force
                    Stop-Process -Name explorer -Force
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""

                    Start-Sleep -Seconds 3
                    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
                    Start-Process "explorer.exe"
                    }
                }
                if ($regstate -eq "Enable") {
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -PropertyType String -Value "$env:SystemRoot\System32\shell32.dll,-50" -Force
                    Stop-Process -Name explorer -Force
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""

                    Start-Sleep -Seconds 3
                    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
                    Start-Process "explorer.exe"
                    }
                }
                Draw-Banner
                Write-Host "`n`n`n`n`n`n`n"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})" -NewLine
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
                Write-Host ""
                do {
                    $notice = [Console]::ReadKey($true).Key
                } until ($notice)
                page-two
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
            $regstate = Check-RegistryParameter-CPanel
            if ($regstate -eq "Disable") {
                Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
                page-two
            }
            if ($regstate -eq "Enable") {
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID") -like "False" -or $(Test-Path -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}") -like "False"){
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID") -like "False"){New-Item -Path "HKCU:\Software\Classes\CLSID"}
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}") -like "False") {New-Item -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Force}
                    New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord -Value 1
                    page-two
                } else { 
                    if ($(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null){
                        New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord -Value 1
                        page-two
                    } else {
                        Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{26EE0668-A00A-44D7-9371-BEB064C98683}" -Name "System.IsPinnedToNameSpaceTree" -Value 1
                        page-two
                    }
                }
            }
        }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
            $regstate = Check-RegistryParameter-Trash
            if ($regstate -eq "Disable") {
                Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
                page-two
            }
            if ($regstate -eq "Enable") {
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID") -like "False" -or $(Test-Path -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}") -like "False"){
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID") -like "False"){New-Item -Path "HKCU:\Software\Classes\CLSID"}
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}") -like "False") {New-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Force}
                    New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord -Value 1
                    page-two
                } else { 
                    if ($(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null){
                        New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord -Value 1 
                        page-two
                    } else {
                        Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Name "System.IsPinnedToNameSpaceTree" -Value 1
                        page-two
                    }
                }
            }
        }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                $regstate = Check-RegistryParameter-Permanently-Delete

                if ($regstate -eq "Enable"){
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""
                    New-Item -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete"
                    New-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "CommandStateSync" -PropertyType String
                    New-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "ExplorerCommandHandler" -PropertyType String
                    New-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "Icon" -PropertyType String
                    New-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "Position" -PropertyType String

                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""

                    Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "ExplorerCommandHandler" -Value "{E9571AB2-AD92-4ec6-8924-4E5AD33790F5}"
                    Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "Icon" -Value "shell32.dll,-240"
                    Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Name "Position" -Value "Bottom"
                    Start-Sleep -Seconds 1
                }

                if ($regstate -eq "Disable"){
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""

                    Remove-Item -Path "HKCR:\AllFilesystemObjects\shell\Windows.PermanentDelete" -Recurse
                    Start-Sleep -Seconds 1
                }
                Draw-Banner
                Write-Host "`n`n`n`n`n`n`n"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})" -NewLine
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
                Write-Host ""
                do {
                    $notice = [Console]::ReadKey($true).Key
                } until ($notice)
                page-two
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){ Action-choose }
            if (($choice -eq "A") -or ($choice -eq "LeftArrow")){ Action-choose }
            if ($choice -eq "Escape"){ Action-choose }
            } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "A") -or ($choice -eq "Escape")) #Выход из цикла
            }
    #endregion

    #region Первая страница
    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Select action"})" -NewLine

    if ($win_ver -like "*Windows 10*") {
    Align-TextCenter "[$([char]27)[48;5;0m$([char]27)[38;5;10;4m1$([char]27)[24m] $(if($Menu_Lang -eq "ru-Ru"){"Скрыть все папки в «Этот Компьютер»"} else {"Hide Folders in This PC"})"} elseif ($win_ver -like "*Windows 11*"){Align-TextCenter "$(if($(Check-RegistryParameter-Win11Classic) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Win11Classic)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-Win11Classic) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Вернуть классический стить контекстного меню"} else {"Return Classic Contect Menu Style"})"}
    Align-TextCenter "$(if($(Check-RegistryParameter-ThisPC) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-ThisPC)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-ThisPC) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Открывать «Этот компьютер» в проводнике вместо «Домой»"} else {"Open 'This PC' in File Explorer instead of Home"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-QuickAccess) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-QuickAccess)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-QuickAccess) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Отключить автоматическое добавление папок для «Быстрый доступ»"} else {"Disable Auto Adding Folders to «Quick access»"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-BingSearch) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-BingSearch)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-BingSearch) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Отключить поиск в Bing"} else {"Disable Bing search in Search"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-SystemUsesLightTheme) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-SystemUsesLightTheme)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-SystemUsesLightTheme) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Тёмная тема системы"} else {"Dark system theme"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-AppsUseLightTheme) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-AppsUseLightTheme)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if($(Check-RegistryParameter-AppsUseLightTheme) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Тёмная тема приложений"} else {"Dark theme for apps"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-OneDrive) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-OneDrive)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-OneDrive) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть OneDrive с панели проводника"} else {"Hide OneDrive from the Sidebar"})"
    Align-TextCenter "$(if($(Check-RegistryParameter-Network) -eq "Disable") {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) $([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(Check-RegistryParameter-Network)$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m $(if ($(Check-RegistryParameter-Network) -eq "Enable") {" "})| $(if($Menu_Lang -eq "ru-Ru"){"Скрыть сеть на панели проводника"} else {"Hide Network from the Sidebar"})"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mВыход в меню$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack to menu$([char]27)[0m"})"
    Write-Host "`n"
    Center-Text "$grn$(if($Menu_Lang -eq "ru-Ru"){"Страница 1"} else {"Page 1"})"
    Center-Text "$grn            [D] ->"
    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            if ($win_ver -like "*Windows 10*") {
                this-pc
            } elseif ($win_ver -like "*Windows 11*"){
                $regstate = Check-RegistryParameter-Win11Classic
                
                if ($regstate -eq "Enable"){
                    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Force
                    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force
                    Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Value ""

                    Stop-Process -Name explorer -Force
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""

                    Start-Sleep -Seconds 3
                    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
                    Start-Process "explorer.exe"
                    }
                    Draw-Banner
                    Write-Host "`n`n`n`n`n`n`n"
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})" -NewLine
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
                    Write-Host ""
                    do {
                        $notice = [Console]::ReadKey($true).Key
                    } until ($notice)
                    Action-choose
                }
                if ($regstate -eq "Disable"){
                    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse
                    Action-choose
                }
            }
            
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            $regstate = Check-RegistryParameter-ThisPC
            if ($regstate -eq "Disable") {
                Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo"
                Action-choose    
            }
            if ($regstate -eq "Enable") {
                New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -PropertyType DWord -Value 1
                Action-choose
            }
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            $regstate = Check-RegistryParameter-QuickAccess
            if ($regstate -eq "Disable") {
                Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 1
                Action-choose
            }
            if ($regstate -eq "Enable"){
                Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
                Action-choose
            }
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
            $regstate = Check-RegistryParameter-BingSearch
            if ($regstate -eq "Disable") {
                Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 1
                Action-choose
            }
            if ($regstate -eq "Enable"){
                if ($(Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -ErrorAction SilentlyContinue) -eq $null) { New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -PropertyType DWord }
                Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
                Action-choose
            }
        }
        if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                $regstate = Check-RegistryParameter-SystemUsesLightTheme
                if ($regstate -eq "Enable"){Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value "0" -Type "Dword"}
                if ($regstate -eq "Disable"){Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value "1" -Type "Dword"}
                if ($(Get-WmiObject Win32_OperatingSystem).Caption -match "Windows 11"){
                    Stop-Process -Name explorer -Force
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                    Write-Host ""
                    Start-Sleep -Seconds 3
                    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {Start-Process "explorer.exe"}
                }
                Draw-Banner
                Write-Host "`n`n`n`n`n`n`n"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})" -NewLine
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
                Write-Host ""
                do {
                    $notice = [Console]::ReadKey($true).Key
                } until ($notice)
                Action-choose
            }
        if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
            $regstate = Check-RegistryParameter-AppsUseLightTheme
            if ($regstate -eq "Enable"){Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value "0" -Type "Dword"}
            if ($regstate -eq "Disable"){Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value "1" -Type "Dword"}
            if ($(Get-WmiObject Win32_OperatingSystem).Caption -match "Windows 11"){
                Stop-Process -Name explorer -Force
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"В процессе..."} else {"Processing..."})"
                Write-Host ""
                Start-Sleep -Seconds 3
                if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {Start-Process "explorer.exe"}
            }
            Draw-Banner
            Write-Host "`n`n`n`n`n`n`n"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})" -NewLine
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
            Write-Host ""
            do {
                $notice = [Console]::ReadKey($true).Key
            } until ($notice)
            Action-choose
        }
        if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
            $regstate = Check-RegistryParameter-OneDrive
            if ($regstate -eq "Disable") {
                Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 1
                Action-choose
            }
            if ($regstate -eq "Enable"){
                if ( $(Test-Path -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}") -Like "False"){ New-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" }
                if ($(Get-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null) { New-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord }
                Set-ItemProperty -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
                Action-choose
            }
        }
        if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
            $regstate = Check-RegistryParameter-Network
            if ($regstate -eq "Disable") {
                Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -Value 1
                Action-choose
            }
            if ($regstate -eq "Enable"){
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID") -Like "False"){New-Item -Path "HKCU:\Software\Classes\CLSID"}
                if ($(Test-Path -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}") -Like "False"){New-Item -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"}
                if ($(Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue) -eq $null) {New-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -PropertyType DWord}
                Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -Value 0
                Action-choose
            }
        }
        if (($choice -eq "D9") -or ($choice -eq "NumPad9")){ Goto-main }
        if (($choice -eq "D") -or ($choice -eq "RightArrow")){ page-two }
        if ($choice -eq "Escape"){ Goto-main }
        } until ($choice -eq "Escape")
        #endregion

}
#endregion


#Начало
Action-choose
