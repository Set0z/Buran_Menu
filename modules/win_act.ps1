#Объявление глобальных переменных
$host.ui.RawUI.WindowTitle = ""
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Выбор версии Windows"} else {$host.ui.RawUI.WindowTitle = "Windows Version Selection"})
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
Set-ConsoleColor 'black' 'green'
}

#Выбор версии
function Version-selection {
Draw-Banner
Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите версию Windows"} else {"Select the Windows version"})"
Write-Host ""
Write-Host "                 [1] Windows 10 Home/Pro"
Write-Host ""
Write-Host "                 [2] Windows 11 Home/Pro"
Write-Host ""
Write-Host "                 $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mВыход в меню$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack to menu$([char]27)[0m"})"
do {
    $choice = [Console]::ReadKey($true).Key            #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
    $win_ver = "win10" 
    Action-selection
    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
    $win_ver = "win11"
    Action-selection
    }
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){ Goto-main }
    if ($choice -eq "Escape"){ Goto-main }
} until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
$host.ui.RawUI.WindowTitle = "Windows Actions"
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Выбор действия"} else {$host.ui.RawUI.WindowTitle = "Action selection"})
}

#Выбор действия
function Action-selection {
Draw-Banner
Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Select the action"})"
Write-Host ""
Write-Host "                 [1] $(if($Menu_Lang -eq "ru-Ru"){"Активировать/Продлить Windows"} else {"Activate/Renew Windows"})"
Write-Host ""
Write-Host "                 [2] $(if($Menu_Lang -eq "ru-Ru"){"Деактивировать Windows"} else {"Deactivate Windows"})"
Write-Host ""
Write-Host "                 $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"
Write-Host ""
do {
    $choice = [Console]::ReadKey($true).Key            #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        if ($win_ver -eq "win10") {
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Активация..."} else {"Activation..."})"
        slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
        Start-Sleep -Seconds 7
        slmgr /skms kms.digiboy.ir
        Start-Sleep -Seconds 7
        slmgr /ato
        Start-Sleep -Seconds 10
        }
        if ($win_ver -eq "win11") {
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Активация..."} else {"Activation..."})"
        slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
        Start-Sleep -Seconds 7
        slmgr /skms kms.digiboy.ir
        Start-Sleep -Seconds 7
        slmgr /ato
        Start-Sleep -Seconds 10
        }
    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
        if ($win_ver -eq "win10") {
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Деактивация..."} else {"Deactivation..."})"
        slmgr /upk
        Start-Sleep -Seconds 3
	    slmgr /cpky
        Start-Sleep -Seconds 5
        }
        if ($win_ver -eq "win11") {
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Деактивация..."} else {"Deactivation..."})"
        slmgr /upk
        Start-Sleep -Seconds 3
	    slmgr /cpky
        Start-Sleep -Seconds 5
        }
    }
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){ Version-selection }
    if ($choice -eq "Escape"){ Version-selection }
} until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла

slmgr /xpr                  #вывод информаии об активации

Start-Sleep -Seconds 3

Draw-Banner
Write-Host ""
Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выполнено!"} else {"Done!"})"
Write-Host "`n`n`n"

}

Version-selection   #Запуск
pause
Goto-main