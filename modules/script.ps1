#Объявление глобальных переменных
$(if($PSCulture -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "B.U.R.A.N. Меню"} else {$host.ui.RawUI.WindowTitle = "B.U.R.A.N. Menu"})
$env:version = "1.1"
$ver= $env:version
if ($PSScriptRoot -eq "") {
    if(($(Get-ExecutionPolicy) -eq "Restricted") -or ($(Get-ExecutionPolicy) -eq "AllSigned")) {
        Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/script.ps1 | iex"'
        exit
    }
    $env:script_state = "Internet"
    if (Test-Path $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1')) {Remove-Item $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -Force}
    irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/modules.psm1" >> $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1')
    Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking
} elseif ($PSScriptRoot -ne "") {
    $scriptDir = $PSScriptRoot
    Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking
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

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Set-ConsoleColor 'black' 'Magenta' '1'
    Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Скрипт запущен не от имени администратора! (ВАЖНО)"} else {"The script is not running with administrator privileges! (IMPORTANT)"})" -NewLine
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Перезапустить с правами администратора?"} else {"Restart with administrator privileges?"})"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[1] Да [2] Нет"} else {"[1] Yes [2] No"})"
    do {
    $choice = [Console]::ReadKey($true).Key #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        if ($env:script_state -eq "Internet"){
            Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-Command", "`$env:BURAN_lang = '$Menu_Lang'; irm 'https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/script.ps1' | iex"
            exit
        } else {
            Start-Process powershell -Verb RunAs -ArgumentList "-NoExit", "-ExecutionPolicy Bypass", "-Command", "`$env:BURAN_lang = '$Menu_Lang'; & `"$PSScriptRoot\script.ps1`""
            exit
        }
    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
        Set-ConsoleColor 'black' 'Magenta' '1'
        Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Некоторые функции могут не работать!"} else {"Some functions may not work!"})"
        Write-Host "`n`n`n"
        pause
    }
} until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))) #Выход из программы
}






#Отрисовка меню
Draw-Banner -Text_Color "Green"
Set-ConsoleColor 'black' 'Magenta'
Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine
Align-TextCenter "[1] $(if($Menu_Lang -eq "ru-Ru"){"Активация Windows 10/11"} else {"Windows 10/11 Activation"})"
Align-TextCenter "[2] $(if($Menu_Lang -eq "ru-Ru"){"Конфигурация Удалённого Рабочего Стола"} else {"Remoute Desktop Configuration"})"
Align-TextCenter "[3] $(if($Menu_Lang -eq "ru-Ru"){"Скачивание/Активация Microsoft Office"} else {"Microsoft Office Download/Activation"})"
Align-TextCenter "[4] $(if($Menu_Lang -eq "ru-Ru"){"UAC Настройки"} else {"UAC Settings"})"
Align-TextCenter "[5] $(if($Menu_Lang -eq "ru-Ru"){"Настройки реестра"} else {"Registry settings"})"
Align-TextCenter "[6] $(if($Menu_Lang -eq "ru-Ru"){"Установка и обновление приложений (Winget)"} else {"App Upgrade and Install (winget)"})"
Align-TextCenter "$([char]27)[48;5;13m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;13m$([char]27)[38;5;0mВыход$([char]27)[48;5;0m"} else {"$([char]27)[48;5;13m$([char]27)[38;5;0mExit$([char]27)[48;5;0m"})"

#Цикл отрисовки и считывания нажатий
do {

    $choice = [Console]::ReadKey($true).Key #считывание нажатия
    #Write-Host "Вы нажали: $choice"
    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        if ($env:script_state -eq "Internet") {irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/win_act.ps1" | iex}
        $filePath = Join-Path -Path $scriptDir -ChildPath 'win_act.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
        if ($env:script_state -eq "Internet") {irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/rem_desk.ps1" | iex}
        $filePath = Join-Path -Path $scriptDir -ChildPath 'rem_desk.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
        if ($env:script_state -eq "Internet") {irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/office_new.ps1" | iex}
        $filePath = Join-Path -Path $scriptDir -ChildPath 'office_new.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
        if ($env:script_state -eq "Internet") {irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/uac_ch.ps1" | iex}
        $filePath = Join-Path -Path $scriptDir -ChildPath 'uac_ch.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
        if ($env:script_state -eq "Internet") {irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/reg_settings.ps1" | iex}
        $filePath = Join-Path -Path $scriptDir -ChildPath 'reg_settings.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
    if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
        if ($env:script_state -eq "Internet") {irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/app_install.ps1" | iex}
        $filePath = Join-Path -Path $scriptDir -ChildPath 'app_install.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"")
        exit
    }
    if (($choice -eq "D7") -or ($choice -eq "NumPad7") -or ($choice -eq "Escape")){
        exit
    }
} until ($choice -eq "D7") #Выход из программы

#pause