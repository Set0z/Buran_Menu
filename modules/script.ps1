#Объявление глобальных переменных
$(if($PSCulture -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "B.U.R.A.N. Меню"} else {$host.ui.RawUI.WindowTitle = "B.U.R.A.N. Menu"})
$scriptDir = $PSScriptRoot
$env:version = "0.1"
$ver= $env:version
$filePath = Join-Path -Path $scriptDir -ChildPath 'win_act.ps1'





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

if ($env:BURAN_lang -eq $null){
    Set-ConsoleColor 'black' 'Magenta' '1'
    Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
    Center-Text "Select Language"
    Center-Text "[1] English   [2] Russian"
    do {
        $choice = [Console]::ReadKey($true).Key #считывание нажатия
        #Write-Host "Вы нажали: $choice"
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            $env:BURAN_lang = "en-US"
            $Menu_Lang = "en-US"
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            $env:BURAN_lang = "ru-RU"
            $Menu_Lang = "ru-RU"
        }
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or ($choice -eq "Escape")) #Выход из программы
} else {$Menu_Lang = $env:BURAN_lang}

#Отрисовка меню
function Draw-Banner {
Set-ConsoleColor 'black' 'green' '1'
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
Set-ConsoleColor 'black' 'Magenta'
Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})"
Write-Host ""
Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Активация Windows 10/11"} else {"Windows 10/11 Activation"})"
Write-Host ""
Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Конфигурация Удалённого Рабочего Стола"} else {"Remoute Desktop Configuration"})"
Write-Host ""
Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Скачивание/Активация Microsoft Office"} else {"Microsoft Office Download/Activation"})"
Write-Host ""
Write-Host "                  [4] $(if($Menu_Lang -eq "ru-Ru"){"UAC Настройки"} else {"UAC Settings"})"
Write-Host ""
Write-Host "                  [5] $(if($Menu_Lang -eq "ru-Ru"){"Настройки реестра"} else {"Registry settings"})"
Write-Host ""
Write-Host "                  [6] $(if($Menu_Lang -eq "ru-Ru"){"Установка и обновление приложений (Winget)"} else {"App Upgrade and Install (winget)"})"
Write-Host ""
Write-Host "                  $([char]27)[48;5;13m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;13m$([char]27)[38;5;0mВыход$([char]27)[48;5;0m"} else {"$([char]27)[48;5;13m$([char]27)[38;5;0mExit$([char]27)[48;5;0m"})"
}
Draw-Banner #вызов функции отрисовки

#Цикл отрисовки и считывания нажатий
do {

    $choice = [Console]::ReadKey($true).Key #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        $filePath = Join-Path -Path $scriptDir -ChildPath 'win_act.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
        $filePath = Join-Path -Path $scriptDir -ChildPath 'rem_desk.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
        $filePath = Join-Path -Path $scriptDir -ChildPath 'office_new.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
        $filePath = Join-Path -Path $scriptDir -ChildPath 'uac_ch.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
        $filePath = Join-Path -Path $scriptDir -ChildPath 'reg_settings.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
        $filePath = Join-Path -Path $scriptDir -ChildPath 'app_install.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"")
        exit
    }
} until ((($choice -eq "D7") -or ($choice -eq "NumPad7")) -or ($choice -eq "Escape")) #Выход из программы

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" -Name "ExecutionPolicy" -Value "Restricted"
#pause