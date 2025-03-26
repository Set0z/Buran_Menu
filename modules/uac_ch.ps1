#Объявление глобальных переменных
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "UAC Политика"} else {$host.ui.RawUI.WindowTitle = "UAC Policy"})
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
$ver= $env:version

if ($PSScriptRoot -eq "") {
    irm "https://raw.githubusercontent.com/Set0z/Test_ps/refs/heads/main/modules.psm1" >> $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1')
    Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking
} else {
    $scriptDir = $PSScriptRoot
    Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking
}


function Action-choose {
    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})"
    Write-Host ""
    Write-Host "                  $(if(((($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin) -eq 2)) -and (($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop").PromptOnSecureDesktop) -eq 1)) {"$([char]27)[48;5;10m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;10m"} else {"[1]"}) $(if($Menu_Lang -eq "ru-Ru"){"Всегда уведомлять"} else {"Always notify"})"
    Write-Host ""
    Write-Host "                  $(if(((($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin) -eq 1)) -and (($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop").PromptOnSecureDesktop) -eq 1)) {"$([char]27)[48;5;10m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;10m"} else {"[2]"}) $(if($Menu_Lang -eq "ru-Ru"){"Всегда уведомлять с паролем"} else {"Always notify with password"})"
    Write-Host ""
    Write-Host "                  $(if(((($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin) -eq 5)) -and (($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop").PromptOnSecureDesktop) -eq 1)) {"$([char]27)[48;5;10m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;10m"} else {"[3]"}) $(if($Menu_Lang -eq "ru-Ru"){"Уведомлять только тогда, когда программы пытаются внести изменения в мой компьютер (по умолчанию)"} else {"Notify only when programs try to make changes to my computer (Default)"})"
    Write-Host ""
    Write-Host "                  $(if(((($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin) -eq 5)) -and (($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop").PromptOnSecureDesktop) -eq 0)) {"$([char]27)[48;5;10m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;10m"} else {"[4]"}) $(if($Menu_Lang -eq "ru-Ru"){"Уведомлять без запроса на безопасном рабочем столе"} else {"Notify without prompt on secure Desktop"})"
    Write-Host ""
    Write-Host "                  $(if(((($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin").ConsentPromptBehaviorAdmin) -eq 0)) -and (($(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop").PromptOnSecureDesktop) -eq 0)) {"$([char]27)[48;5;10m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;10m"} else {"[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Никогда не уведомлять — UAC отключен"} else {"Never notify - UAC is disabled"})"
    Write-Host ""
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mВыход в меню$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack to menu$([char]27)[0m"})"
    do {
    $choice = [Console]::ReadKey($true).Key            #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1
    Action-choose

    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1
    Action-choose

    }
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1
    Action-choose

    }
    if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 5
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0
    Action-choose

    }
    if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0
    Action-choose

    }
    if (($choice -eq "D6") -or ($choice -eq "NumPad6")){ Goto-main }
    if ($choice -eq "Escape"){ Goto-main }
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
}

#Начало
Action-choose