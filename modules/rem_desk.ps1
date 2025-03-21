﻿#Объявление глобальных переменных
$host.ui.RawUI.WindowTitle = ""
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Конфигурация удаленного рабочего стола"} else {$host.ui.RawUI.WindowTitle = "Remoute Desktop Configuration"})
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
Write-Host "`n"
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
Write-Host "`n"
Set-ConsoleColor 'Black' 'White'
}

#Функция проверки работы профилей
function Check-FirewallStatus($name) {
    # Получаем результат фильтрации
    $firewallState = Get-NetFirewallProfile | Where-Object { ($_.Name -eq $name) }

    if ($firewallState.Enabled -eq $true) {
        return "Enabled"
    } else {
        return "Disabled"
    }
}

#Функция проверки всего фаервола
function Get-FirewallStatus {
    # Проверяем состояние брандмауэра для всех профилей
    $firewallStatus = (Get-NetFirewallProfile | Where-Object {($_.Enabled -eq $true) -and ($_.Name -ne 'Domain')})

    if ($firewallStatus) {
        return "Enabled"
    } else {
        return "Disabled"
    }
}




#                                                          Начало



Draw-Banner
if($Menu_Lang -eq "ru-Ru"){
    $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mВключить удаленный рабочий стол на этом компьютере?$([char]27)[48;5;0m$([char]27)[38;5;11m"
    $message = " "

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Включить удаленный рабочий стол"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Пропустить этот шаг"
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", "Выход"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit)
    $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
    $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
} else {
    $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mEnable remote desktop on this computer?$([char]27)[48;5;0m$([char]27)[38;5;11m"
    $message = " "

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Activate Remoute Desktop"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip this step"
    $exit = New-Object System.Management.Automation.Host.ChoiceDescription "&Exit", "Exit"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no, $exit)
    $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
    $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
}
if ($choice -eq 0) {
    Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "updateRDStatus" -Value 1
    net start termservice
}
if ($choice -eq 2) {Goto-main}




if (($(Check-FirewallStatus 'Domain') -eq "Disabled") -or ($(Check-FirewallStatus 'Private') -eq "Disabled") -or ($(Check-FirewallStatus 'Public') -eq "Disabled")){
    Draw-Banner
    if($Menu_Lang -eq "ru-Ru"){
        $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mВключить брандмауэр Windows? (Необходимо для белого списка IP)$([char]27)[48;5;0m$([char]27)[38;5;11m"
        $message = "$([char]27)[48;5;0m$([char]27)[38;5;13mТекущее состояние: $([char]27)[48;5;0m$([char]27)[38;5;13;4mДомен$([char]27)[24m: $(Check-FirewallStatus 'Domain') | $([char]27)[48;5;0m$([char]27)[38;5;13;4mЧастный$([char]27)[24m: $(Check-FirewallStatus 'Private') | $([char]27)[48;5;0m$([char]27)[38;5;13;4mПубличный$([char]27)[24m: $(Check-FirewallStatus 'Public')$([char]27)[48;5;0m$([char]27)[38;5;15m"

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Включение профилей брандмауэра Windows (домен, частный, общедоступный)"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Пропустить этот шаг"

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
        $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
    } else {
        $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mEnable Windows Firewall? (Need for Ip whitelist)$([char]27)[48;5;0m$([char]27)[38;5;11m"
        $message = "$([char]27)[48;5;0m$([char]27)[38;5;13mCurrent state: $([char]27)[48;5;0m$([char]27)[38;5;13;4mDomain$([char]27)[24m: $(Check-FirewallStatus 'Domain') | $([char]27)[48;5;0m$([char]27)[38;5;13;4mPrivate$([char]27)[24m: $(Check-FirewallStatus 'Private') | $([char]27)[48;5;0m$([char]27)[38;5;13;4mPublic$([char]27)[24m: $(Check-FirewallStatus 'Public')$([char]27)[48;5;0m$([char]27)[38;5;15m"

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Anable Windows Firewall (Domain, Private, Publice) profiles"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip this step"

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
        $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
    }
    
    if ($choice -eq 0) {
        Set-NetFirewallProfile -All -Enabled True
    }
}



if ($(Get-FirewallStatus) -eq "Enabled"){


    if($Menu_Lang -eq "ru-Ru"){
        Draw-Banner
        $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mВключить белый список IP-адресов?$([char]27)[48;5;0m$([char]27)[38;5;11m"
        $message = " "

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Активировать пул IP-адресов из белого списка"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Пропустить этот шаг"

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
        $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
    } else {
        Draw-Banner
        $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mEnable IP whitelist?$([char]27)[48;5;0m$([char]27)[38;5;11m"
        $message = " "

        $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Activate Whitelist Ip Pool"
        $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip this step"

        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
        $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
    }
    if ($choice -eq 0) {
    Draw-Banner
    # Запрос у пользователя IP-адресов
    $ipAddresses = @()

    do {
        $ip = Read-Host "Enter the IP address (or press Enter to finish)"
        if ($ip -ne "") {
            $ipAddresses += $ip
        }
    } while ($ip -ne "")

    # Формирование строки с IP-адресами
    $ipString = $ipAddresses -join '|RA4='

    # Вставка IP-адресов в команду
    $command = "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules' -Name 'RemoteDesktop-UserMode-In-TCP' -Value 'v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=3389|RA4=$ipString|App=%SystemRoot%\system32\svchost.exe|Svc=termservice|Name=@FirewallAPI.dll,-28775|Desc=@FirewallAPI.dll,-28756|EmbedCtxt=@FirewallAPI.dll,-28752|'"

    # Выполнение команды
    Invoke-Expression $command
}
}



if($Menu_Lang -eq "ru-Ru"){
    Draw-Banner
    $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mРазрешить вход с пустым паролем?$([char]27)[48;5;0m$([char]27)[38;5;11m"
    $message = " "

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Разрешить пустой пароль (если у пользователя нет пароля)"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Пропустить этот шаг"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
    $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)  
} else {
    Draw-Banner
    $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mEnable login with blank password?$([char]27)[48;5;0m$([char]27)[38;5;11m"
    $message = " "

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Allow Blank Password (If user don't have password)"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip this step"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
    $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
}

if ($choice -eq 0) {
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "LimitBlankPasswordUse" /t REG_DWORD /d 0 /f
}


if($Menu_Lang -eq "ru-Ru"){
    Draw-Banner
    $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mПоказать данные для входа?$([char]27)[48;5;0m$([char]27)[38;5;11m"
    $message = " "

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Вывести имя пользователя и IP-адрес!"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Пропустить этот шаг"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
    $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
} else {
    Draw-Banner
    $title = "$([char]27)[48;5;0m$([char]27)[38;5;13mShow login details?$([char]27)[48;5;0m$([char]27)[38;5;11m"
    $message = " "

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Print Username and IP addreses!"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Skip this step"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    $defaultChoice = 0  # 0 означает, что по умолчанию будет выбрано "Yes"
    $choice = $host.ui.PromptForChoice($title, $message, $options, $defaultChoice)
}



if ($choice -eq 0) {
    Draw-Banner
    Set-ConsoleColor 'black' 'green'
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Данные для входа: "} else {"Login details: "})"
    Write-Host "`n"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Пользователь:"} else {"User:"}) $Env:UserName"
    Write-Host ""
    $ipAddress = (Get-NetIPAddress -InterfaceAlias Ethernet* -AddressFamily IPv4).IPAddress
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"IPv4 Адресс:"} else {"IPv4 Adress:"}) $ipAddress"
    Write-Host "`n"
}

pause
Goto-main