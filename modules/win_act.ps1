#region Объявление переменных
$host.ui.RawUI.WindowTitle = ""
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
$win_ver = (Get-WmiObject Win32_OperatingSystem).Caption
if ($PSScriptRoot -eq "") {Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking} else {$scriptDir = $PSScriptRoot ; Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking}

$kmsList = @(
    "kms.digiboy.ir"
    "hq1.chinancce.com"
    "54.223.212.31"
    "kms.cnlic.com"
    "kms.chinancce.com"
    "kms.ddns.net"
    "franklv.ddns.net"
    "k.zpale.com"
    "m.zpale.com"
    "mvg.zpale.com"
    "kms.shuax.com"
    "kensol263.imwork.net:1688"
    "xykz.f3322.org"
    "kms789.com"
    "dimanyakms.sytes.net:1688"
    "kms.03k.org:1688"
)

$cscript = "$env:SystemRoot\System32\cscript.exe"
$slmgr = "$env:SystemRoot\System32\slmgr.vbs"

$sel = "$([char]27)[48;5;2;38;5;0m"   # зелёный фон, черный текст, выделенный
$grn = "$([char]27)[48;5;0;38;5;2m"   # черный фон, зеленый текст
#endregion

function MainPage {
    $(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Выбор действия 🔑"} else {$host.ui.RawUI.WindowTitle = "Action selection 🔑"})
    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
    Align-TextCenter "[1] $(if($Menu_Lang -eq "ru-Ru"){"Активировать/Продлить Windows (KMS)"} else {"Activate/Renew Windows (KMS)"})"
    Align-TextCenter "[2] $(if($Menu_Lang -eq "ru-Ru"){"Деактивировать Windows"} else {"Deactivate Windows"})"
    Align-TextCenter "[3] $(if($Menu_Lang -eq "ru-Ru"){"Узнать время до истечения активации"} else {"Show time before activation expiration"})"
    Align-TextCenter "$sel[4]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Выход в меню$grn"} else {"${sel}Back to menu$grn"})" -NewLine

    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            Draw-Banner
            $(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Активация 🔑"} else {$host.ui.RawUI.WindowTitle = "Activation 🔑"})
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Активация..."} else {"Activation..."})" -NewLine
            & $cscript //NoLogo $slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
            foreach ($kms in $kmsList) {
                Center-Text "$(if($PSCulture -eq "ru-Ru"){"Попытка активации через ${sel}${kms}${grn}`n"} else {"Attempting to activate via ${sel}${kms}${grn}`n"})"
                & $cscript //NoLogo $slmgr /skms "$kms`:1688"
                $output = & $cscript //NoLogo $slmgr /ato
                $output
                if (($output -match "успешно") -or ($output -match "successfully")) {break}
            }
            $status = & $cscript //NoLogo $slmgr /xpr
            if (-not ($status -match "истечет|expire")) {& $cscript //NoLogo $slmgr /ato}
            Start-Sleep 5
            slmgr /xpr
            Draw-Banner
            Center-Text "Done!`n"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
            do {
                $notice = [Console]::ReadKey($true).Key
            } until ($notice)
            MainPage
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            Draw-Banner
            $(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Деактивация 🔑"} else {$host.ui.RawUI.WindowTitle = "Deactivation 🔑"})
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Деактивация..."} else {"Deactivation..."})" -NewLine
            & $cscript //NoLogo $slmgr /upk
            & $cscript //NoLogo $slmgr /cpky
            & $cscript //NoLogo $slmgr /ckms
            Start-Sleep 5
            Draw-Banner
            Center-Text "Done!`n"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
            do {
                $notice = [Console]::ReadKey($true).Key
            } until ($notice)
            MainPage
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){slmgr /xpr ; MainPage}
        if (($choice -eq "D4") -or ($choice -eq "NumPad4") -or ($choice -eq "Escape")){Goto-main}
    } until ($choice -eq "Escape")
}

MainPage
