#region Объявление переменных
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "UAC Политика 🔐"} else {$host.ui.RawUI.WindowTitle = "UAC Policy 🔐"})
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
if ($PSScriptRoot -eq "") {Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking} else {$scriptDir = $PSScriptRoot ; Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking}
$sel = "$([char]27)[48;5;2;38;5;0m"   # зелёный фон, черный текст, выделенный
$grn = "$([char]27)[48;5;0;38;5;2m"   # черный фон, зеленый текст
#endregion

function Action-choose {
    $BehaviorA = $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin
    $SecurureD = $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop").PromptOnSecureDesktop

    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
    Align-TextCenter "$(if(($BehaviorA -eq 2) -and ($SecurureD -eq 1)){"${sel}[1]$grn"} else {"[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Всегда уведомлять"} else {"Always notify"})"
    Align-TextCenter "$(if(($BehaviorA -eq 1) -and ($SecurureD -eq 1)){"${sel}[2]$grn"} else {"[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Всегда уведомлять с паролем"} else {"Always notify with password"})"
    Align-TextCenter "$(if(($BehaviorA -eq 5) -and ($SecurureD -eq 1)){"${sel}[3]$grn"} else {"[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Уведомлять только тогда, когда программы пытаются внести изменения в мой компьютер (по умолчанию)"} else {"Notify only when programs try to make changes to my computer (Default)"})"
    Align-TextCenter "$(if(($BehaviorA -eq 5) -and ($SecurureD -eq 0)){"${sel}[4]$grn"} else {"[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Уведомлять без запроса на безопасном рабочем столе"} else {"Notify without prompt on secure Desktop"})"
    Align-TextCenter "$(if(($BehaviorA -eq 0) -and ($SecurureD -eq 0)){"${sel}[5]$grn"} else {"[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Никогда не уведомлять — UAC отключен"} else {"Never notify - UAC is disabled"})"
    Align-TextCenter "${sel}[6]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Выход в меню$grn"} else {"${sel}Back to menu$grn"})"

    do {
    $choice = [Console]::ReadKey($true).Key
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 ; Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1 ; Action-choose}
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 1 ; Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1 ; Action-choose}
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5 ; Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1 ; Action-choose}
    if (($choice -eq "D4") -or ($choice -eq "NumPad4")){Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5 ; Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0 ; Action-choose}
    if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 ; Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0 ; Action-choose}
    if (($choice -eq "D6") -or ($choice -eq "NumPad6")){ Goto-main }
    if ($choice -eq "Escape"){ Goto-main }
    } until (($choice -eq "NumPad6") -or ($choice -eq "Escape"))
}

Action-choose