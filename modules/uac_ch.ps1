#Объявление глобальных переменных
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "UAC Политика"} else {$host.ui.RawUI.WindowTitle = "UAC Policy"})
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
$ver= $env:version

#Функция смены цвета фона и текста ('цвет фона', 'цвет текста', 'нужна ли очистка консоли')
function Set-ConsoleColor ($bc, $fc, $cl) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    if ($cl -eq 1) { 
        Clear-Host
    }
}

function Center-Text {
    param (
        [string]$Text
    )

    # Удаляем управляющие последовательности (цветовые коды ANSI)
    $cleanText = $Text -replace '\x1b\[[0-9;]*m', ''

    # Получаем ширину консоли
    $consoleWidth = ([console]::WindowWidth) - 3

    # Вычисляем количество пробелов для отступа
    $padding = [math]::Max(0, ($consoleWidth - $cleanText.Length) / 2)

    # Формируем строку с отступом
    $centeredText = " " * [math]::Floor($padding) + $Text

    # Выводим текст
    Write-Host $centeredText
}

#Функция возвращения в главное меню
function Goto-main {
    $filePath = Join-Path -Path $scriptDir -ChildPath 'script.ps1'
    Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
    exit
}

#Отрисовка меню
function Draw-Banner {
Set-ConsoleColor 'black' 'Magenta' '1'
Write-Host ""
Write-Host ""
Write-Host "                   ███████████     █████  █████    ███████████        █████████      ██████   █████"
Write-Host "                  ░░███░░░░░███   ░░███  ░░███    ░░███░░░░░███      ███░░░░░███    ░░██████ ░░███"
Write-Host "                   ░███    ░███    ░███   ░███     ░███    ░███     ░███    ░███     ░███░███ ░███"
Write-Host "                   ░██████████     ░███   ░███     ░██████████      ░███████████     ░███░░███░███"
Write-Host "                   ░███░░░░░███    ░███   ░███     ░███░░░░░███     ░███░░░░░███     ░███ ░░██████"
Write-Host "                   ░███    ░███    ░███   ░███     ░███    ░███     ░███    ░███     ░███  ░░█████"
Write-Host "                   ███████████  ██ ░░████████   ██ █████   █████ ██ █████   █████ ██ █████  ░░█████ ██"
Write-Host "                  ░░░░░░░░░░░  ░░   ░░░░░░░░   ░░ ░░░░░   ░░░░░ ░░ ░░░░░   ░░░░░ ░░ ░░░░░    ░░░░░ ░░"
Write-Host ""
Write-Host ""
Write-Host "                                 ██████   ██████ ██████████ ██████   █████ █████  █████"                      
Write-Host "                                ░░██████ ██████ ░░███░░░░░█░░██████ ░░███ ░░███  ░░███"
Write-Host "                                 ░███░█████░███  ░███  █ ░  ░███░███ ░███  ░███   ░███"
Write-Host "                                 ░███░░███ ░███  ░██████    ░███░░███░███  ░███   ░███"
Write-Host "                                 ░███ ░░░  ░███  ░███░░█    ░███ ░░██████  ░███   ░███"
Write-Host "                                 ░███      ░███  ░███ ░   █ ░███  ░░█████  ░███   ░███"
Write-Host "                                 █████     █████ ██████████ █████  ░░█████ ░░████████"
Write-Host "                                ░░░░░     ░░░░░ ░░░░░░░░░░ ░░░░░    ░░░░░   ░░░░░░░░"
Write-Host ""
Center-Text "(c) Set0z - https://github.com/Set0z"
Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Версия $($ver)"} else {"Version $($ver)"})"
Write-Host ""
Set-ConsoleColor 'black' 'Green'
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