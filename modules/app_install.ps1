﻿#Глобальные переменные
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Установка & Обновление"} else {$host.ui.RawUI.WindowTitle = "Update & Install"})
$ver= $env:version
$downloadsPath = Join-Path $HOME "Downloads"
$global:winget_programs = New-Object System.Collections.ArrayList
Import-Module $($PSScriptRoot + "/modules")

$Debug = $false

<###Функция возвращения в главное меню
function Goto-main {
    $filePath = Join-Path -Path $scriptDir -ChildPath 'script.ps1'
    Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
    exit
}

#Функция смены цвета фона и текста ('цвет фона', 'цвет текста', 'нужна ли очистка консоли')
function Set-ConsoleColor ($bc, $fc, $cl) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    if ($cl -eq 1) { 
        Clear-Host
    }
}

#Отрисовка меню
function Draw-Banner {

param (
    [string]$Text_Color = "Magenta",
    [string]$Background_Color = "Black",
    [string]$Clear = 1
)
Set-ConsoleColor $Background_Color $Text_Color  $Clear
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
Write-Host ""
Set-ConsoleColor 'black' 'Green'
}

#Отображения текста по центру
function Center-Text {
    param (
        [string]$Text
    )

    # Удаляем управляющие последовательности (цветовые коды ANSI)
    $cleanText = $Text -replace '\x1b\[[0-9;]*m', ''

    # Получаем ширину консоли
    $consoleWidth = ([console]::WindowWidth)

    # Вычисляем количество пробелов для отступа
    $padding = [math]::Max(0, ($consoleWidth - $cleanText.Length) / 2)

    # Формируем строку с отступом
    $centeredText = " " * [math]::Floor($padding) + $Text

    # Выводим текст
    Write-Host $centeredText
}

#Загрузка файла
function Download-FileWithProgress {
    param (
        [string]$url,          # URL файла для скачивания
        [string]$outputFile    # Путь для сохранения файла
    )

    # Загружаем тип HttpClient
    Add-Type -AssemblyName System.Net.Http

    # Создаем новый объект HttpClient
    $httpClient = [System.Net.Http.HttpClient]::new()

    # Получаем ответ от сервера (не скачиваем сразу)
    $response = $httpClient.GetAsync($url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

    # Проверяем успешность запроса
    if ($response.IsSuccessStatusCode) {
        # Получаем общий размер файла в байтах
        $totalSize = $response.Content.Headers.ContentLength

        # Преобразуем размер в мегабайты
        $totalSizeMB = [math]::Round($totalSize / 1MB, 2)

        # Открываем файл для записи
        $fileStream = [System.IO.File]::Create($outputFile)

        # Читаем контент с прогрессом
        $buffer = New-Object byte[] 8192  # Буфер для загрузки
        $bytesRead = 0
        $totalBytesRead = 0

        # Чтение контента с прогрессом
        $contentStream = $response.Content.ReadAsStreamAsync().Result
        $lastProgressUpdateTime = Get-Date

        if($Menu_Lang -eq 'ru-Ru'){
            while (($bytesRead = $contentStream.ReadAsync($buffer, 0, $buffer.Length).Result) -gt 0) {
            # Пишем данные в файл
            $fileStream.Write($buffer, 0, $bytesRead)
            $totalBytesRead += $bytesRead

            # Выводим прогресс только раз в 2 секунды для снижения нагрузки
            $currentTime = Get-Date
            if (($currentTime - $lastProgressUpdateTime).TotalSeconds -gt 2) {
                # Преобразуем загруженные байты в мегабайты
                $totalBytesReadMB = [math]::Round($totalBytesRead / 1MB, 1)
                
                $percentComplete = ($totalBytesRead / $totalSize) * 100
                Write-Progress -PercentComplete $percentComplete -Status "Загрузка файла..." -Activity "Загружено: $totalBytesReadMB MB из $totalSizeMB MB"
                
                $lastProgressUpdateTime = $currentTime
            }
            }
        } else {
            while (($bytesRead = $contentStream.ReadAsync($buffer, 0, $buffer.Length).Result) -gt 0) {
            # Пишем данные в файл
            $fileStream.Write($buffer, 0, $bytesRead)
            $totalBytesRead += $bytesRead

            # Выводим прогресс только раз в 2 секунды для снижения нагрузки
            $currentTime = Get-Date
            if (($currentTime - $lastProgressUpdateTime).TotalSeconds -gt 2) {
                # Преобразуем загруженные байты в мегабайты
                $totalBytesReadMB = [math]::Round($totalBytesRead / 1MB, 1)
                
                $percentComplete = ($totalBytesRead / $totalSize) * 100
                Write-Progress -PercentComplete $percentComplete -Status "File download..." -Activity "Downloaded: $totalBytesReadMB MB из $totalSizeMB MB"
                
                $lastProgressUpdateTime = $currentTime
            }
            }
        }
        # Закрываем поток и выводим сообщение
        $fileStream.Close()
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Файл успешно скачан!"} else {"File is successfully downloaded!"})"
        Write-Host ""
        } else {
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Ошибка при скачивании файла. Код ошибки: $($response.StatusCode)"} else {"Error while downloading file. Error code: $($response.StatusCode)"})"
        Write-Host ""
    }
}

#Выбор папки
function Folder-choose {

    param (
        [bool]$default = $true
    )
    Add-Type -AssemblyName System.Windows.Forms
    
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $(if ($default -eq $true) {if($Menu_Lang -eq "ru-Ru"){$folderBrowser.Description = "Выберите папку (при отмене будет выбрана Загрузки)"} else {$folderBrowser.Description = "Select a folder (if canceled, Downloads will be selected)"}} else {if($Menu_Lang -eq "ru-Ru"){$folderBrowser.Description = "Выберите папку"} else {$folderBrowser.Description = "Select a folder"}})
    $folderBrowser.ShowNewFolderButton = $true

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowser.SelectedPath
        return $selectedPath
    } else {
       if ($default -eq $true){return $downloadsPath}
    }
}

#Выбор файла
function Select-File {
    param (
        [string]$Title = "Выберите файл",
        [string]$Filter = "JSON (*.json)|*.json"
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = $Title
    $dialog.Filter = $Filter
    
    if ($dialog.ShowDialog() -eq "OK") {
        return $dialog.FileName
    } else {
        return $null
    }
}

#Определение размера файла
function File-size ($url){
    $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing
    $totalSize = [math]::Round($response.Headers["Content-Length"] / 1MB, 2)
    return $totalSize
}

#Вывод списка устанавливаемых приложений
function Print-Programs {
    param (
        [string[]]$programs,   # Массив программ
        [int]$maxWidth = 105    # Максимальная ширина строки (по умолчанию 80 символов)
    )

    $currentLine = ""
    $i = 1
    foreach ($program in $programs) {
        
        $formattedProgram = "[$($i)] $program   |   "
        $i++
        if (($currentLine.Length + $formattedProgram.Length) -lt $maxWidth) {
            $currentLine += $formattedProgram
        } else {
            Write-Host "           $($currentLine.TrimEnd())"
            Write-Host ""
            $currentLine = $formattedProgram
        }
    }
    if ($currentLine.Length -gt 0) {
        Write-Host "           $($currentLine.TrimEnd())"
        Write-Host ""
    }
    
}

#Проверка наличия winget
function Winget-Check {
    Draw-Banner
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Main-menu
    } else {
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){Center-Text "Winget не установлен"} else {Center-Text "Winget is not installed"})"
        Write-Host ""
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){Center-Text "Установить?"} else {Center-Text "Install?"})"
        Write-Host "`n"
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){Center-Text "[1] Да   [2] Нет"} else {Center-Text "[1] Yes   [2]No"})"
        Write-Host ""
        Center-Text "File size: ($([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(File-size 'https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb + $(File-size 'https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb)"
        do {
            $choice = [Console]::ReadKey($true).Key            #считывание нажатия
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                $downloadFolder = Folder-choose

                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){Center-Text "Загрузка..."} else {Center-Text "Dowloading..."})"
                Write-Host "`n"
                Center-Text "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

                $totalSize = File-size "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
                $downloadFolder_main = Join-Path $downloadFolder "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

                Download-FileWithProgress -url "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -outputFile $downloadFolder_main

                Start-Sleep -Seconds 3
                Draw-Banner
                Write-Host "`n"

                Add-AppxPackage -Path $downloadFolder -ErrorAction SilentlyContinue
                if ($?) {

                    Write-Host "НЕТ ОШИБКИ"

                } else {
                    
                    $downloadFolder_dep = Join-Path $downloadFolder "DesktopAppInstaller_Dependencies.zip"

                    Download-FileWithProgress -url "https://github.com/microsoft/winget-cli/releases/latest/download/DesktopAppInstaller_Dependencies.zip" -outputFile $downloadFolder_dep

                    #Разархивированиеl
                    $zipPath = "$downloadFolder\DesktopAppInstaller_Dependencies.zip"
                    $extractTo = $downloadFolder
                    $x64Folder = "x64"
                    $tempFolder = Join-Path $extractTo "temp"
                    Expand-Archive -Path $zipPath -DestinationPath $tempFolder
                    $x64Files = Get-ChildItem -Path (Join-Path $tempFolder $x64Folder) -File
                    foreach ($file in $x64Files) {
                        Copy-Item -Path $file.FullName -Destination $extractTo
                    }
                    Remove-Item -Path $tempFolder -Recurse -Force

                    $downloadsPath_dep1 = Join-Path $downloadFolder "Microsoft.UI*"
                    $downloadsPath_dep2 = Join-Path $downloadFolder "Microsoft.VCLibs*"

                    $file_dep1 = Get-ChildItem -Path $downloadsPath_dep1 | Select-Object -First 1
                    $file_dep2 = Get-ChildItem -Path $downloadsPath_dep2 | Select-Object -First 1

                    Add-AppxPackage -Path $file_dep1.FullName
                    Add-AppxPackage -Path $file_dep2.FullName
                    Add-AppxPackage -Path $downloadFolder_main

                    Remove-Item -Path $downloadFolder_dep -Recurse -Force
                    Remove-Item -Path $downloadFolder_main -Recurse -Force
                    Remove-Item -Path $file_dep1.FullName -Recurse -Force
                    Remove-Item -Path $file_dep2.FullName -Recurse -Force
                }
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){Center-Text "Готово!"} else {Center-Text "Done!"})"
                Write-Host ""
                pause
                $filePath = Join-Path -Path $scriptDir -ChildPath 'app_install.ps1'
                Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
                exit
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){Goto-main}
            if ($choice -eq "Escape"){ Goto-main }
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or ($choice -eq "Escape")) #Выход из цикла
    }
}

#Сохранение и чтение конфига
function Manage_WingetPrograms {
    param (
        [string]$FilePath,
        [string]$Mode  # read/write
    )

    if ($Mode -eq "write") {
        $global:winget_programs | ConvertTo-Json | Set-Content -Path $FilePath
    }
    elseif ($Mode -eq "read") {
        if (Test-Path $FilePath) {
            $global:winget_programs = Get-Content -Path $FilePath | ConvertFrom-Json
        }
    }
}

#Парсинг строки
function search_parsing{
    for ($i = 1; $i -lt $global:winget_search.Count; $i++) {

        #Остановка на перых 9 строчках
        if($i -eq 10) {break}

        $active_string = $global:winget_search[$i]
        if($active_string.IndexOf("Moniker:") -ne -1) {$tag_pos = $active_string.IndexOf("Moniker:")} else {}
        if($active_string.IndexOf("Command:") -ne -1) {$tag_pos = $active_string.IndexOf("Command:")} else {}
        if($active_string.IndexOf("Tag:") -ne -1) {$tag_pos = $active_string.IndexOf("Tag:")} else {}
        #$tag_pos
        if ($tag_pos -ne $null) {
            $active_string = $active_string.Substring(0,$tag_pos)
        }

        #Write-Host "$active_string|`n"
        for ($j = $($active_string.Length -1); $j -ge 0; $j--) {
            if ($active_string[$j] -ne ' '){
            $active_string = $active_string.Substring(0, $j + 1)
            break
            }
        }
        for ($j = $($active_string.Length -1); $j -ge 0; $j--) {
            if ($active_string[$j] -eq ' '){
            $active_string = $active_string.Substring(0, $j + 1)
            break
            }
        }
        for ($j = $($active_string.Length -1); $j -ge 0; $j--) {
            if ($active_string[$j] -ne ' '){
            $active_string = $active_string.Substring(0, $j + 1)
            break
            }
        }
        for ($j = $($active_string.Length -1); $j -ge 0; $j--) {
            if ($active_string[$j] -eq ' '){
            $id_name = $active_string.Substring($j + 1)
            $global:id.Add($id_name) | Out-Null
            $active_string = $active_string.Substring(0, $j + 1)
            break
            }
        }
        for ($j = $($active_string.Length -1); $j -ge 0; $j--) {
            if ($active_string[$j] -ne ' '){
            $active_string = $active_string.Substring(0, $j + 1)
            break
            }
        } 
        $global:names.Add($active_string) | Out-Null
        #Write-Host "$active_string|"
    }
}

#Запись вывода winget в массив
function winget_search {
    
    
    param (
        [string]$Search_Word
    )

    

    #запись в массив вывода команды (считывать с 1 номера)
    $global:winget_search = New-Object System.Collections.ArrayList
    $global:id = New-Object System.Collections.ArrayList
    $global:names = New-Object System.Collections.ArrayList

    #вызов winget
    winget search -q "$Search_Word" -s winget -n 9 | ForEach-Object {
        if ($_ -match "^[-]+$") {
            $skip = $true
        }
        if ($skip) {
            $global:winget_search.Add($_) | Out-Null
        }
    }

    search_parsing
}

#Добавление пробела в вывод search
function add_space{
    param (
        [string]$name_space
    )
    $space_length = 50 - $name_space.Length
    for ($i = 1; $i -ne $space_length; $i++) {
        $space = $space + " "
    }
    return $space
}

function programs_print {
    param (
        [string]$exit_to
    )
    do {            
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host "`n"
        Print-Programs -programs $winget_programs
        Write-Host "`n"
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[Tab] Удалить пакет по номеру"} else {"[Tab] Delete Package by Number"})       $(if($Menu_Lang -eq "ru-Ru"){"[Пробел] Очистить всё"} else {"[Space] Сlear everything"})"
        Write-Host ""
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[Esc] Назад"} else {"[Esc] Back"})"
        Write-Host "`n"

        $choice = [Console]::ReadKey($true).Key
        if ($choice -eq "Spacebar"){
            Draw-Banner
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Вы точно хотите обновить все установленные приложения?"} else {"Are you sure you want to update all the installed apps?"})`n"
            Center-Text "[1] $(if($Menu_Lang -eq "ru-Ru"){"Да"} else {"Yes"})   [2] $(if($Menu_Lang -eq "ru-Ru"){"Нет"} else {"No"})"
            do {
                $choice = [Console]::ReadKey($true).Key
                if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                    $global:winget_programs = New-Object System.Collections.ArrayList                   
                }
            } until (($choice -eq "D1") -or ($choice -eq "NumPad1"))
        }
        if ($choice -eq "Tab"){
            Draw-Banner
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
            Write-Host "`n"
            Print-Programs -programs $winget_programs
            Write-Host "`n"
            Write-Host "$(if($Menu_Lang -eq "ru-Ru"){"                                                    Номер пакета: "} else {"                                                    Package number: "})" -NoNewline
            $del_number = Read-Host
            $global:winget_programs = [System.Collections.ArrayList]$global:winget_programs
            $global:winget_programs.RemoveAt($del_number - 1)
        }
        if ($choice -eq "Escape"){& $exit_to}
        } until ($choice -eq "Escape")
}

function installation{
    if ($winget_programs[0] -eq $null) {
                    Draw-Banner
                    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Ничего не выбрано для установки!"} else {"Nothing is chosen for installation!"})"
                    Write-Host ""
                    pause
                    Main-menu
                }
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Будут установлены следующие пакеты:"} else {"The following packages will be installed:"})"
                Write-Host ""
                Print-Programs -programs $winget_programs
                Write-Host "`n"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Установить?"} else {"Install?"})"
                Write-Host ""
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[1] Да   [2] Нет"} else {"[1] Yes   [2] No"})"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        Main-menu
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))

                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите режим установки:"} else {"Select the installation mode:"})"
                Write-Host ""
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[1] Обычный (рекомендуется)   [2] Тихий"} else {"[1] Normal (recommended) [2] Silent"})"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                        Draw-Banner -Text_Color "White" -Background_Color "DarkMagenta" -Clear "1"
                        Set-ConsoleColor "DarkMagenta" "White"
                        winget install -e $winget_programs -i --accept-package-agreements
                    }
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        Draw-Banner -Text_Color "White" -Background_Color "DarkMagenta" -Clear "1"
                        Set-ConsoleColor "DarkMagenta" "White"
                        winget install -e $winget_programs -h --accept-package-agreements
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
                Write-Host ""
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})"
                pause
                $winget_programs.Clear()
                Main-menu
}
###>



#Функции меню
function Audio{

    function Audio-Players{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Аудио >> Аудио Плееры"} else {"Audio >> Audio Players"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("PeterPawlowski.foobar2000")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Foobar2000 `n"
        Write-Host "                  $(if($winget_programs.Contains("AIMP.AIMP")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) AIMP `n"
        Write-Host "                  $(if($winget_programs.Contains("Audacious.MediaPlayer")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Audacious `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("PeterPawlowski.foobar2000")){$winget_programs.Remove("PeterPawlowski.foobar2000")} else {$winget_programs.Add("PeterPawlowski.foobar2000") | Out-Null}
               Audio-Players
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("AIMP.AIMP")){$winget_programs.Remove("AIMP.AIMP")} else {$winget_programs.Add("AIMP.AIMP") | Out-Null}
               Audio-Players
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("Audacious.MediaPlayer")){$winget_programs.Remove("Audacious.MediaPlayer")} else {$winget_programs.Add("Audacious.MediaPlayer") | Out-Null}
               Audio-Players
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Audio-Players"
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){Audio}
            if ($choice -eq "Escape"){Audio}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Audio-Recording{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Аудио >> Аудиозапись"} else {"Audio >> Audio Recording"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Audacity.Audacity")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Audacity `n"
        Write-Host "                  $(if($winget_programs.Contains("Ocenaudio.Ocenaudio")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Ocenaudio `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("Audacity.Audacity")){$winget_programs.Remove("Audacity.Audacity")} else {$winget_programs.Add("Audacity.Audacity") | Out-Null}
               Audio-Recording
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("Ocenaudio.Ocenaudio")){$winget_programs.Remove("Ocenaudio.Ocenaudio")} else {$winget_programs.Add("Ocenaudio.Ocenaudio") | Out-Null}
               Audio-Recording
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Audio-Recording"
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Audio}
            if ($choice -eq "Escape"){Audio}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Music-Notation{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Аудио >> Музыкальная нотация"} else {"Audio >> Music Notation"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Denemo.Denemo")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Denemo `n"
        Write-Host "                  $(if($winget_programs.Contains("WilbertBerendsen.Frescobaldi")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Frescobaldi `n"
        Write-Host "                  $(if($winget_programs.Contains("LilyPond.LilyPond")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) LilyPond `n"
        Write-Host "                  $(if($winget_programs.Contains("Musescore.Musescore")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) MuseScore `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("Denemo.Denemo")){$winget_programs.Remove("Denemo.Denemo")} else {$winget_programs.Add("Denemo.Denemo") | Out-Null}
               Music-Notation
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("WilbertBerendsen.Frescobaldi")){$winget_programs.Remove("WilbertBerendsen.Frescobaldi")} else {$winget_programs.Add("WilbertBerendsen.Frescobaldi") | Out-Null}
               Music-Notation
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("LilyPond.LilyPond")){$winget_programs.Remove("LilyPond.LilyPond")} else {$winget_programs.Add("LilyPond.LilyPond") | Out-Null}
               Music-Notation
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("Musescore.Musescore")){$winget_programs.Remove("Musescore.Musescore")} else {$winget_programs.Add("Musescore.Musescore") | Out-Null}
               Music-Notation
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Music-Notation"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Audio}
            if ($choice -eq "Escape"){Audio}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Music-Production{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Аудио >> Музыкальное продюсирование"} else {"Audio >> Music Production"})Production"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("LMMS.LMMS")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) LMMS `n"
        Write-Host "                  $(if($winget_programs.Contains("BandLab.Cakewalk")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Cakewalk `n"
        Write-Host "                  $(if($winget_programs.Contains("tildearrow.Furnace")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Furnace `n"
        Write-Host "                  $(if($winget_programs.Contains("MilkyTracker.MilkyTracker")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) MilkyTracker `n"
        Write-Host "                  $(if($winget_programs.Contains("OpenMPT.OpenMPT")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) OpenMPT `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("LMMS.LMMS")){$winget_programs.Remove("LMMS.LMMS")} else {$winget_programs.Add("LMMS.LMMS") | Out-Null}
               Music-Production
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("BandLab.Cakewalk")){$winget_programs.Remove("BandLab.Cakewalk")} else {$winget_programs.Add("BandLab.Cakewalk") | Out-Null}
               Music-Production
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("tildearrow.Furnace")){$winget_programs.Remove("tildearrow.Furnace")} else {$winget_programs.Add("tildearrow.Furnace") | Out-Null}
               Music-Production
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("MilkyTracker.MilkyTracker")){$winget_programs.Remove("MilkyTracker.MilkyTracker")} else {$winget_programs.Add("MilkyTracker.MilkyTracker") | Out-Null}
               Music-Production
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
               if($winget_programs.Contains("OpenMPT.OpenMPT")){$winget_programs.Remove("OpenMPT.OpenMPT")} else {$winget_programs.Add("OpenMPT.OpenMPT") | Out-Null}
               Music-Production
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Music-Production"
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){Audio}
            if ($choice -eq "Escape"){Audio}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
    }


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Аудио"} else {"Audio"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("FxSound.FxSound")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) FXSound `n"
    Write-Host "                  $(if($winget_programs.Contains("File-New-Project.EarTrumpet")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) EarTrumpet `n"
    Write-Host "                  $(if($winget_programs.Contains("JeniusApps.Ambie")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Ambie `n"
    Write-Host "                  [4] $(if($Menu_Lang -eq "ru-Ru"){"Аудиоплееры\"} else {"Audio Players\"})`n"
    Write-Host "                  [5] $(if($Menu_Lang -eq "ru-Ru"){"Аудиозапись\"} else {"Audio Recording\"})`n"
    Write-Host "                  [6] $(if($Menu_Lang -eq "ru-Ru"){"Музыкальная нотация\"} else {"Music Notation\"})`n"
    Write-Host "                  [7] $(if($Menu_Lang -eq "ru-Ru"){"Музыкальное продюсирование\"} else {"Music Production\"})`n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("FxSound.FxSound")){$winget_programs.Remove("FxSound.FxSound")} else {$winget_programs.Add("FxSound.FxSound") | Out-Null}
               Audio
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("File-New-Project.EarTrumpet")){$winget_programs.Remove("File-New-Project.EarTrumpet")} else {$winget_programs.Add("File-New-Project.EarTrumpet") | Out-Null}
               Audio
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("JeniusApps.Ambie")){$winget_programs.Remove("JeniusApps.Ambie")} else {$winget_programs.Add("JeniusApps.Ambie") | Out-Null}
               Audio
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                Audio-Players
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                Audio-Recording
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                Music-Notation
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                Music-Production
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Audio"
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){Main-menu}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Browsers{

    function Browsers-page-two{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Браузеры"} else {"Browsers"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Brave.Brave")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Brave `n"
        Write-Host "                  $(if($winget_programs.Contains("LibreWolf.LibreWolf")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) LibreWolf `n"
        Write-Host "                  $(if($winget_programs.Contains("MoonchildProductions.PaleMoon")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Pale Moon `n"
        Write-Host "                  $(if($winget_programs.Contains("qutebrowser.qutebrowser")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Qutebrowser `n"
        Write-Host "                  $(if($winget_programs.Contains("MullvadVPN.MullvadBrowser")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Mullvad Browser `n"
        Write-Host "                  $(if($winget_programs.Contains("Vivaldi.Vivaldi")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) Vivaldi `n"
        Write-Host "                  $(if($winget_programs.Contains("Zen-Team.Zen-Browser")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Zen Browser `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Страница 2"} else {"Page 2"})"
        Write-Host "                                                   <- [A]"
    

        do {
                $choice = [Console]::ReadKey($true).Key
                if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                    if($winget_programs.Contains("Brave.Bravee")){$winget_programs.Remove("Brave.Brave")} else {$winget_programs.Add("Brave.Brave") | Out-Null}
                    Browsers-page-two
                }
                if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                    if($winget_programs.Contains("LibreWolf.LibreWolf")){$winget_programs.Remove("LibreWolf.LibreWolf")} else {$winget_programs.Add("LibreWolf.LibreWolf") | Out-Null}
                    Browsers-page-two
                }
                if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                    if($winget_programs.Contains("MoonchildProductions.PaleMoon")){$winget_programs.Remove("MoonchildProductions.PaleMoon")} else {$winget_programs.Add("MoonchildProductions.PaleMoon") | Out-Null}
                    Browsers-page-two
                }
                if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                    if($winget_programs.Contains("qutebrowser.qutebrowser")){$winget_programs.Remove("qutebrowser.qutebrowser")} else {$winget_programs.Add("qutebrowser.qutebrowser") | Out-Null}
                    Browsers-page-two
                }
                if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                    if($winget_programs.Contains("MullvadVPN.MullvadBrowser")){$winget_programs.Remove("MullvadVPN.MullvadBrowser")} else {$winget_programs.Add("MullvadVPN.MullvadBrowser") | Out-Null}
                    Browsers-page-two
                }
                if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                    if($winget_programs.Contains("Vivaldi.Vivaldi")){$winget_programs.Remove("Vivaldi.Vivaldi")} else {$winget_programs.Add("Vivaldi.Vivaldi") | Out-Null}
                    Browsers-page-two
                }
                if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                    if($winget_programs.Contains("Zen-Team.Zen-Browser")){$winget_programs.Remove("Zen-Team.Zen-Browser")} else {$winget_programs.Add("Zen-Team.Zen-Browser") | Out-Null}
                    Browsers-page-two
                }
                if ($choice -eq "F2"){
	                programs_print -exit_to "Browsers-page-two"
                }
                if (($choice -eq "D8") -or ($choice -eq "NumPad9")){Browsers}
                if ($choice -eq "A"){Browsers}
                if ($choice -eq "Escape"){Browsers}
            } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or ($choice -eq "A") -or ($choice -eq "Escape")) #Выход из цикла
        }


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Браузеры"} else {"Browsers"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("Google.Chrome")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Chrome `n"
    Write-Host "                  $(if($winget_programs.Contains("Opera.OperaGX")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Opera GX `n"
    Write-Host "                  $(if($winget_programs.Contains("Opera.Opera")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Opera `n"
    Write-Host "                  $(if($winget_programs.Contains("Mozilla.Firefox")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Firefox `n"
    Write-Host "                  $(if($winget_programs.Contains("Hibbiki.Chromium")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Chromium `n"
    Write-Host "                  $(if($winget_programs.Contains("eloston.ungoogled-chromium")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) Ungoogled-Chromium `n"
    Write-Host "                  $(if($winget_programs.Contains("TorProject.TorBrowser")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Tor Browser `n"
    Write-Host "                  $(if($winget_programs.Contains("TheBrowserCompany.Arc")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) Arc `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Страница 1"} else {"Page 1"})"
    Center-Text "            [D] ->"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Google.Chrome")){$winget_programs.Remove("Google.Chrome")} else {$winget_programs.Add("Google.Chrome") | Out-Null}
                Browsers
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Opera.OperaGX")){$winget_programs.Remove("Opera.OperaGX")} else {$winget_programs.Add("Opera.OperaGX") | Out-Null}
                Browsers
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Opera.Opera")){$winget_programs.Remove("Opera.Opera")} else {$winget_programs.Add("Opera.Opera") | Out-Null}
                Browsers
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("Mozilla.Firefox")){$winget_programs.Remove("Mozilla.Firefox")} else {$winget_programs.Add("Mozilla.Firefox") | Out-Null}
                Browsers
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("Hibbiki.Chromium")){$winget_programs.Remove("Hibbiki.Chromium")} else {$winget_programs.Add("Hibbiki.Chromium") | Out-Null}
                Browsers
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("eloston.ungoogled-chromium")){$winget_programs.Remove("eloston.ungoogled-chromium")} else {$winget_programs.Add("eloston.ungoogled-chromium") | Out-Null}
                Browsers
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("TorProject.TorBrowser")){$winget_programs.Remove("TorProject.TorBrowser")} else {$winget_programs.Add("TorProject.TorBrowser") | Out-Null}
                Browsers
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                if($winget_programs.Contains("TheBrowserCompany.Arc")){$winget_programs.Remove("TheBrowserCompany.Arc")} else {$winget_programs.Add("TheBrowserCompany.Arc") | Out-Null}
                Browsers
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Browsers"
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Main-menu}
            if ($choice -eq "D"){Browsers-page-two}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "D") -or ($choice -eq "Escape")) #Выход из цикла
}

function Communication{

    function Messaging{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Общение >> Мессенджеры"} else {"Communication >> Messaging"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Discord.Discord")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Discord `n"
        Write-Host "                  $(if($winget_programs.Contains("Telegram.TelegramDesktop")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Telegram Desktop `n"
        Write-Host "                  $(if($winget_programs.Contains("Rakuten.Viber")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Viber `n"
        Write-Host "                  $(if($winget_programs.Contains("Microsoft.Teams.Free")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Microsoft Teams `n"
        Write-Host "                  $(if($winget_programs.Contains("Microsoft.Skype")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Skype `n"
        Write-Host "                  $(if($winget_programs.Contains("TeamSpeakSystems.TeamSpeakClient")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) TeamSpeak `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("Discord.Discord")){$winget_programs.Remove("Discord.Discord")} else {$winget_programs.Add("Discord.Discord") | Out-Null}
               Messaging
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("Telegram.TelegramDesktop")){$winget_programs.Remove("Telegram.TelegramDesktop")} else {$winget_programs.Add("Telegram.TelegramDesktop") | Out-Null}
               Messaging
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("Rakuten.Viber")){$winget_programs.Remove("Rakuten.Viber")} else {$winget_programs.Add("Rakuten.Viber") | Out-Null}
               Messaging
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("Microsoft.Teams.Free")){$winget_programs.Remove("Microsoft.Teams.Free")} else {$winget_programs.Add("Microsoft.Teams.Free") | Out-Null}
               Messaging
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
               if($winget_programs.Contains("Microsoft.Skype")){$winget_programs.Remove("Microsoft.Skype")} else {$winget_programs.Add("Microsoft.Skype") | Out-Null}
               Messaging
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
               if($winget_programs.Contains("TeamSpeakSystems.TeamSpeakClient")){$winget_programs.Remove("TeamSpeakSystems.TeamSpeakClient")} else {$winget_programs.Add("TeamSpeakSystems.TeamSpeakClient") | Out-Null}
               Messaging
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Messaging"
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){Communication}
            if ($choice -eq "Escape"){Communication}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Email_Clients{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Общение >> Почтовые клиенты"} else {"Communication >> Email Clients"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Blix.BlueMail")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) BlueMail `n"
        Write-Host "                  $(if($winget_programs.Contains("VladimirYakovlev.ElectronMail")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) ElectronMail `n"
        Write-Host "                  $(if($winget_programs.Contains("eMClient.eMClient")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) eM Client `n"
        Write-Host "                  $(if($winget_programs.Contains("Tencent.Foxmail")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Foxmail `n"
        Write-Host "                  $(if($winget_programs.Contains("Mailbird.Mailbird")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Mailbird `n"
        Write-Host "                  $(if($winget_programs.Contains("Foundry376.Mailspring")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) Mailspring `n"
        Write-Host "                  $(if($winget_programs.Contains("Postbox.Postbox")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Postbox `n"
        Write-Host "                  $(if($winget_programs.Contains("Mozilla.Thunderbird")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) ThunderBird `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Blix.BlueMail")){$winget_programs.Remove("Blix.BlueMail")} else {$winget_programs.Add("Blix.BlueMail") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("VladimirYakovlev.ElectronMail")){$winget_programs.Remove("VladimirYakovlev.ElectronMail")} else {$winget_programs.Add("VladimirYakovlev.ElectronMail") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("eMClient.eMClient")){$winget_programs.Remove("eMClient.eMClient")} else {$winget_programs.Add("eMClient.eMClient") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("Tencent.Foxmail")){$winget_programs.Remove("Tencent.Foxmail")} else {$winget_programs.Add("Tencent.Foxmail") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("Mailbird.Mailbird")){$winget_programs.Remove("Mailbird.Mailbird")} else {$winget_programs.Add("Mailbird.Mailbird") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("Foundry376.Mailspring")){$winget_programs.Remove("Foundry376.Mailspring")} else {$winget_programs.Add("Foundry376.Mailspring") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("Postbox.Postbox")){$winget_programs.Remove("Postbox.Postbox")} else {$winget_programs.Add("Postbox.Postbox") | Out-Null}
                Email_Clients
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                if($winget_programs.Contains("Mozilla.Thunderbird")){$winget_programs.Remove("Mozilla.Thunderbird")} else {$winget_programs.Add("Mozilla.Thunderbird") | Out-Null}
                Email_Clients
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Email_Clients"
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Communication}
            if ($choice -eq "Escape"){Communication}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
    }




    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Общение"} else {"Communication"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host ""
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Мессенджеры\"} else {"Messaging\"}) `n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Почтовые клиенты\"} else {"Email Clients\"}) `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               Messaging
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               Email_Clients
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Communication"
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Main-menu}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Compression_and_Archiving{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Сжатие и Архивирование"} else {"Compression and Archiving"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("RARLab.WinRAR")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) WinRAR `n"
    Write-Host "                  $(if($winget_programs.Contains("7zip.7zip")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) 7-Zip `n"
    Write-Host "                  $(if($winget_programs.Contains("Bandisoft.Bandizip")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Bandizip `n"
    Write-Host "                  $(if($winget_programs.Contains("muCommander.muCommander")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) muCommander `n"
    Write-Host "                  $(if($winget_programs.Contains("M2Team.NanaZip")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) NanaZip `n"
    Write-Host "                  $(if($winget_programs.Contains("Giorgiotani.Peazip")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) PeaZip `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("RARLab.WinRAR")){$winget_programs.Remove("RARLab.WinRAR")} else {$winget_programs.Add("RARLab.WinRAR") | Out-Null}
                Compression_and_Archiving
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("7zip.7zip")){$winget_programs.Remove("7zip.7zip")} else {$winget_programs.Add("7zip.7zip") | Out-Null}
                Compression_and_Archiving
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Bandisoft.Bandizip")){$winget_programs.Remove("Bandisoft.Bandizip")} else {$winget_programs.Add("Bandisoft.Bandizip") | Out-Null}
                Compression_and_Archiving
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("muCommander.muCommander")){$winget_programs.Remove("muCommander.muCommander")} else {$winget_programs.Add("muCommander.muCommander") | Out-Null}
                Compression_and_Archiving
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("M2Team.NanaZip")){$winget_programs.Remove("M2Team.NanaZip")} else {$winget_programs.Add("M2Team.NanaZip") | Out-Null}
                Compression_and_Archiving
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("Giorgiotani.Peazip")){$winget_programs.Remove("Giorgiotani.Peazip")} else {$winget_programs.Add("Giorgiotani.Peazip") | Out-Null}
                Compression_and_Archiving
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Compression_and_Archiving"
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){Main-menu}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Customize{

    function System_Customization{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Кастомизация >> Кастомизация системы"} else {"Customize >> System Customization"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("winaero.tweaker")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Winaero `n"
        Write-Host "                  $(if($winget_programs.Contains("RamenSoftware.Windhawk")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Windhawk `n"
        Write-Host "                  $(if($winget_programs.Contains("Venturi.HideVolumeOSD")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) HideVolumeOSD `n"
        Write-Host "                  $(if($winget_programs.Contains("valinet.ExplorerPatcher")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) ExplorerPatcher `n"
        Write-Host "                  $(if($winget_programs.Contains("Flow-Launcher.Flow-Launcher")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Flow Launcher `n"
        Write-Host "                  $(if($winget_programs.Contains("ModernFlyouts.ModernFlyouts")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) ModernFlyouts `n"
        Write-Host "                  $(if($winget_programs.Contains("BrianApps.Sizer")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Sizer `n"
        Write-Host "                  $(if($winget_programs.Contains("dremin.RetroBar")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) RetroBar `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("winaero.tweaker")){$winget_programs.Remove("winaero.tweaker")} else {$winget_programs.Add("winaero.tweaker") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("RamenSoftware.Windhawk")){$winget_programs.Remove("RamenSoftware.Windhawk")} else {$winget_programs.Add("RamenSoftware.Windhawk") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("Venturi.HideVolumeOSD")){$winget_programs.Remove("Venturi.HideVolumeOSD")} else {$winget_programs.Add("Venturi.HideVolumeOSD") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("valinet.ExplorerPatcher")){$winget_programs.Remove("valinet.ExplorerPatcher")} else {$winget_programs.Add("valinet.ExplorerPatcher") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
               if($winget_programs.Contains("Flow-Launcher.Flow-Launcher")){$winget_programs.Remove("Flow-Launcher.Flow-Launcher")} else {$winget_programs.Add("Flow-Launcher.Flow-Launcher") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
               if($winget_programs.Contains("ModernFlyouts.ModernFlyouts")){$winget_programs.Remove("ModernFlyouts.ModernFlyouts")} else {$winget_programs.Add("ModernFlyouts.ModernFlyouts") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
               if($winget_programs.Contains("BrianApps.Sizer")){$winget_programs.Remove("BrianApps.Sizer")} else {$winget_programs.Add("BrianApps.Sizer") | Out-Null}
               System_Customization
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
               if($winget_programs.Contains("dremin.RetroBar")){$winget_programs.Remove("dremin.RetroBar")} else {$winget_programs.Add("dremin.RetroBar") | Out-Null}
               System_Customization
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "System_Customization"
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Customize}
            if ($choice -eq "Escape"){Customize}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "NumPad7")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Wallpaper_Tools{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Кастомизация >> Приложения для обоев"} else {"Customize >> Wallpaper Tools"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("rocksdanister.LivelyWallpaper")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Lively Wallpaper `n"
        Write-Host "                  $(if($winget_programs.Contains("Rainmeter.Rainmeter")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Rainmeter `n"
        Write-Host "                  $(if($winget_programs.Contains("kelteseth.ScreenPlay.Beta")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) ScreenPlay `n"
        Write-Host "                  $(if($winget_programs.Contains("t1m0thyj.WinDynamicDesktop")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) WinDynamicDesktop `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("rocksdanister.LivelyWallpaper")){$winget_programs.Remove("rocksdanister.LivelyWallpaper")} else {$winget_programs.Add("rocksdanister.LivelyWallpaper") | Out-Null}
                Wallpaper_Tools
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Rainmeter.Rainmeter")){$winget_programs.Remove("Rainmeter.Rainmeter")} else {$winget_programs.Add("Rainmeter.Rainmeter") | Out-Null}
                Wallpaper_Tools
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("kelteseth.ScreenPlay.Beta")){$winget_programs.Remove("kelteseth.ScreenPlay.Beta")} else {$winget_programs.Add("kelteseth.ScreenPlay.Beta") | Out-Null}
                Wallpaper_Tools
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("t1m0thyj.WinDynamicDesktop")){$winget_programs.Remove("t1m0thyj.WinDynamicDesktop")} else {$winget_programs.Add("t1m0thyj.WinDynamicDesktop") | Out-Null}
                Wallpaper_Tools
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Wallpaper_Tools"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Customize}
            if ($choice -eq "Escape"){Customize}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
    }




    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Кастомизация"} else {"Customize"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Кастомизация системы\"} else {"System Customization\"}) `n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Приложения для обоев\"} else {"Wallpaper Tools\"}) `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               System_Customization
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               Wallpaper_Tools
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Customize"
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Main-menu}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Developer_Tools{

    function Database{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Инструменты для разработки >> Датабазы"} else {"Developer Tools >> Database"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("dbeaver.dbeaver")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) DBeaver `n"
        Write-Host "                  $(if($winget_programs.Contains("beekeeper-studio.beekeeper-studio")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Beekeeper Studio `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("dbeaver.dbeaver")){$winget_programs.Remove("dbeaver.dbeaver")} else {$winget_programs.Add("dbeaver.dbeaver") | Out-Null}
               Database
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("beekeeper-studio.beekeeper-studio")){$winget_programs.Remove("beekeeper-studio.beekeeper-studio")} else {$winget_programs.Add("beekeeper-studio.beekeeper-studio") | Out-Null}
               Database
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Database"
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Developer_Tools}
            if ($choice -eq "Escape"){Developer_Tools}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "NumPad7")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Network_Analysis{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Инструменты для разработки >> Анализ сети"} else {"Developer Tools >> Network Analysis"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("WiresharkFoundation.Wireshark")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Wireshark `n"
        Write-Host "                  $(if($winget_programs.Contains("PortSwigger.BurpSuite.Community")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Burp Suite Community Edition `n"
        Write-Host "                  $(if($winget_programs.Contains("XK72.Charles")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Charles `n"
        Write-Host "                  $(if($winget_programs.Contains("james.james")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) James `n"
        Write-Host "                  $(if($winget_programs.Contains("mitmproxy.mitmproxy")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) mitmproxy `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("WiresharkFoundation.Wireshark")){$winget_programs.Remove("WiresharkFoundation.Wireshark")} else {$winget_programs.Add("WiresharkFoundation.Wireshark") | Out-Null}
                Network_Analysis
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("PortSwigger.BurpSuite.Community")){$winget_programs.Remove("PortSwigger.BurpSuite.Community")} else {$winget_programs.Add("PortSwigger.BurpSuite.Community") | Out-Null}
                Network_Analysis
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("XK72.Charles")){$winget_programs.Remove("XK72.Charles")} else {$winget_programs.Add("XK72.Charles") | Out-Null}
                Network_Analysis
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("james.james")){$winget_programs.Remove("james.james")} else {$winget_programs.Add("james.james") | Out-Null}
                Network_Analysis
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("mitmproxy.mitmproxy")){$winget_programs.Remove("mitmproxy.mitmproxy")} else {$winget_programs.Add("mitmproxy.mitmproxy") | Out-Null}
                Network_Analysis
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Network_Analysis"
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){Developer_Tools}
            if ($choice -eq "Escape"){Developer_Tools}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Virtualization{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Инструменты для разработки >> Виртуализация"} else {"Developer Tools >> Virtualization"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Docker.DockerDesktop")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Docker `n"
        Write-Host "                  $(if($winget_programs.Contains("Oracle.VirtualBox")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) VirtualBox `n"
        Write-Host "                  $(if($winget_programs.Contains("Canonical.Multipass")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Multipass `n"
        Write-Host "                  $(if($winget_programs.Contains("RedHat.Podman-Desktop")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Podman Desktop `n"
        Write-Host "                  $(if($winget_programs.Contains("SoftwareFreedomConservancy.QEMU")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) QEMU `n"
        Write-Host "                  $(if($winget_programs.Contains("SUSE.RancherDesktop")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) Rancher Desktop `n"
        Write-Host "                  $(if($winget_programs.Contains("Hashicorp.Vagrant")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Vagrant `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Docker.DockerDesktop")){$winget_programs.Remove("Docker.DockerDesktop")} else {$winget_programs.Add("Docker.DockerDesktop") | Out-Null}
                Virtualization
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Oracle.VirtualBox")){$winget_programs.Remove("Oracle.VirtualBox")} else {$winget_programs.Add("Oracle.VirtualBox") | Out-Null}
                Virtualization
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Canonical.Multipass")){$winget_programs.Remove("Canonical.Multipass")} else {$winget_programs.Add("Canonical.Multipass") | Out-Null}
                Virtualization
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("RedHat.Podman-Desktop")){$winget_programs.Remove("RedHat.Podman-Desktop")} else {$winget_programs.Add("RedHat.Podman-Desktop") | Out-Null}
                Virtualization
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("SoftwareFreedomConservancy.QEMU")){$winget_programs.Remove("SoftwareFreedomConservancy.QEMU")} else {$winget_programs.Add("SoftwareFreedomConservancy.QEMU") | Out-Null}
                Virtualization
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("SUSE.RancherDesktop")){$winget_programs.Remove("SUSE.RancherDesktop")} else {$winget_programs.Add("SUSE.RancherDesktop") | Out-Null}
                Virtualization
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("Hashicorp.Vagrant")){$winget_programs.Remove("Hashicorp.Vagrant")} else {$winget_programs.Add("Hashicorp.Vagrant") | Out-Null}
                Virtualization
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Virtualization"
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){Developer_Tools}
            if ($choice -eq "Escape"){Developer_Tools}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or ($choice -eq "Escape")) #Выход из цикла
    }


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Инструменты для разработки"} else {"Developer Tools"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Датабазы\"} else {"Databas\e"}) `n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Анализ сети\"} else {"Network Analysis\"}) `n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Виртуализация\"} else {"Virtualization\"}) `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               Database
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               Network_Analysis
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               Virtualization
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Developer_Tools"
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){Main-menu}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Documents{

    function Office_Suites{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Документы >> Офисы"} else {"Documents >> Office Suites"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("TheDocumentFoundation.LibreOffice")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) LibreOffice `n"
        Write-Host "                  $(if($winget_programs.Contains("SoftMaker.FreeOffice.2024")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) FreeOffice `n"
        Write-Host "                  $(if($winget_programs.Contains("ONLYOFFICE.DesktopEditors")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) OnlyOffice `n"
        Write-Host "                  $(if($winget_programs.Contains("Kingsoft.WPSOffice")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) WPS Office `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("TheDocumentFoundation.LibreOffice")){$winget_programs.Remove("TheDocumentFoundation.LibreOffice")} else {$winget_programs.Add("TheDocumentFoundation.LibreOffice") | Out-Null}
               Office_Suites
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("SoftMaker.FreeOffice.2024")){$winget_programs.Remove("SoftMaker.FreeOffice.2024")} else {$winget_programs.Add("SoftMaker.FreeOffice.2024") | Out-Null}
               Office_Suites
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("ONLYOFFICE.DesktopEditors")){$winget_programs.Remove("ONLYOFFICE.DesktopEditors")} else {$winget_programs.Add("ONLYOFFICE.DesktopEditors") | Out-Null}
               Office_Suites
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("Kingsoft.WPSOffice")){$winget_programs.Remove("Kingsoft.WPSOffice")} else {$winget_programs.Add("Kingsoft.WPSOffice") | Out-Null}
               Office_Suites
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Office_Suites"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Documents}
            if ($choice -eq "Escape"){Documents}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function E-book{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Документы >> Электронные книги"} else {"Documents >> E-book"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("DjVuLibre.DjView")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) DjVuLibre `n"
        Write-Host "                  $(if($winget_programs.Contains("calibre.calibre")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Calibre `n"
        Write-Host "                  $(if($winget_programs.Contains("AppByTroye.KoodoReader")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Koodo Reader `n"
        Write-Host "                  $(if($winget_programs.Contains("chrox.Readest")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Readest `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("DjVuLibre.DjView")){$winget_programs.Remove("DjVuLibre.DjView")} else {$winget_programs.Add("DjVuLibre.DjView") | Out-Null}
                E-book
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("calibre.calibre")){$winget_programs.Remove("calibre.calibre")} else {$winget_programs.Add("calibre.calibre") | Out-Null}
                E-book
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("AppByTroye.KoodoReader")){$winget_programs.Remove("AppByTroye.KoodoReader")} else {$winget_programs.Add("AppByTroye.KoodoReader") | Out-Null}
                E-book
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("chrox.Readest")){$winget_programs.Remove("chrox.Readest")} else {$winget_programs.Add("chrox.Readest") | Out-Null}
                E-book
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "E-book"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Documents}
            if ($choice -eq "Escape"){Documents}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function PDF_Tools{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Документы >> PDF инструменты"} else {"Documents >> PDF Tools"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Adobe.Acrobat.Reader.64-bit")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Adobe Acrobat Reader `n"
        Write-Host "                  $(if($winget_programs.Contains("Adobe.Acrobat.Pro")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Adobe Acrobat Pro `n"
        Write-Host "                  $(if($winget_programs.Contains("Foxit.FoxitReader")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Foxit PDF Reader `n"
        Write-Host "                  $(if($winget_programs.Contains("KDE.Okular")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Okular `n"
        Write-Host "                  $(if($winget_programs.Contains("PDFArranger.PDFArranger")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) PDF Arranger `n"
        Write-Host "                  $(if($winget_programs.Contains("geeksoftwareGmbH.PDF24Creator")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) PDF24 `n"
        Write-Host "                  $(if($winget_programs.Contains("Xournal++.Xournal++")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Xournal++ `n"
        Write-Host "                  $(if($winget_programs.Contains("PDFgear.PDFgear")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) PDFGear `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Adobe.Acrobat.Reader.64-bit")){$winget_programs.Remove("Adobe.Acrobat.Reader.64-bit")} else {$winget_programs.Add("Adobe.Acrobat.Reader.64-bit") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Adobe.Acrobat.Pro")){$winget_programs.Remove("Adobe.Acrobat.Pro")} else {$winget_programs.Add("Adobe.Acrobat.Pro") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Foxit.FoxitReader")){$winget_programs.Remove("Foxit.FoxitReader")} else {$winget_programs.Add("Foxit.FoxitReader") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("KDE.Okular")){$winget_programs.Remove("KDE.Okular")} else {$winget_programs.Add("KDE.Okular") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("PDFArranger.PDFArranger")){$winget_programs.Remove("PDFArranger.PDFArranger")} else {$winget_programs.Add("PDFArranger.PDFArranger") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("geeksoftwareGmbH.PDF24Creator")){$winget_programs.Remove("geeksoftwareGmbH.PDF24Creator")} else {$winget_programs.Add("geeksoftwareGmbH.PDF24Creator") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("Xournal++.Xournal++")){$winget_programs.Remove("Xournal++.Xournal++")} else {$winget_programs.Add("Xournal++.Xournal++") | Out-Null}
                PDF_Tools
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                if($winget_programs.Contains("PDFgear.PDFgear")){$winget_programs.Remove("PDFgear.PDFgear")} else {$winget_programs.Add("PDFgear.PDFgear") | Out-Null}
                PDF_Tools
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "PDF_Tools"
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Documents}
            if ($choice -eq "Escape"){Documents}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
    }


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Документы"} else {"Documents"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Офисы\"} else {"Office Suites\"}) `n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Электронные книги\"} else {"E-book\"}) `n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"PDF инструменты\"} else {"PDF Tools\"}) `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               Office_Suites
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               E-book
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               PDF_Tools
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Documents"
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Text_Editors{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Текстовые редакторы"} else {"Text Editors"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("Notepad++.Notepad++")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Notepad++ `n"
    Write-Host "                  $(if($winget_programs.Contains("Microsoft.VisualStudioCode")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Visual Studio Code `n"
    Write-Host "                  $(if($winget_programs.Contains("GitHub.Atom")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Atom `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Notepad++.Notepad++")){$winget_programs.Remove("Notepad++.Notepad++")} else {$winget_programs.Add("Notepad++.Notepad++") | Out-Null}
                Text_Editors
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Microsoft.VisualStudioCode")){$winget_programs.Remove("Microsoft.VisualStudioCode")} else {$winget_programs.Add("Microsoft.VisualStudioCode") | Out-Null}
                Text_Editors
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("GitHub.Atom")){$winget_programs.Remove("GitHub.Atom")} else {$winget_programs.Add("GitHub.Atom") | Out-Null}
                Text_Editors
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Text_Editors"
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Games{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Игровые лаунчеры"} else {"Games"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("Valve.Steam")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Steam `n"
    Write-Host "                  $(if($winget_programs.Contains("Blizzard.BattleNet")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Battle.net `n"
    Write-Host "                  $(if($winget_programs.Contains("Bethesda.Launcher")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Bethesda Launcher `n"
    Write-Host "                  $(if($winget_programs.Contains("ElectronicArts.EADesktop")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) EA App `n"
    Write-Host "                  $(if($winget_programs.Contains("EpicGames.EpicGamesLauncher")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Epic Games Launcher `n"
    Write-Host "                  $(if($winget_programs.Contains("GOG.Galaxy")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) GOG Galaxy `n"
    Write-Host "                  $(if($winget_programs.Contains("ItchIo.Itch")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Itch.io `n"
    Write-Host "                  $(if($winget_programs.Contains("Ubisoft.Connect")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) Ubisoft Connect `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Valve.Steam")){$winget_programs.Remove("Valve.Steam")} else {$winget_programs.Add("Valve.Steam") | Out-Null}
                Games
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Blizzard.BattleNet")){$winget_programs.Remove("Blizzard.BattleNet")} else {$winget_programs.Add("Blizzard.BattleNet") | Out-Null}
                Games
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Bethesda.Launcher")){$winget_programs.Remove("Bethesda.Launcher")} else {$winget_programs.Add("Bethesda.Launcher") | Out-Null}
                Games
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("ElectronicArts.EADesktop")){$winget_programs.Remove("ElectronicArts.EADesktop")} else {$winget_programs.Add("ElectronicArts.EADesktop") | Out-Null}
                Games
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("EpicGames.EpicGamesLauncher")){$winget_programs.Remove("EpicGames.EpicGamesLauncher")} else {$winget_programs.Add("EpicGames.EpicGamesLauncher") | Out-Null}
                Games
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("GOG.Galaxy")){$winget_programs.Remove("GOG.Galaxy")} else {$winget_programs.Add("GOG.Galaxy") | Out-Null}
                Games
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("ItchIo.Itch")){$winget_programs.Remove("ItchIo.Itch")} else {$winget_programs.Add("ItchIo.Itch") | Out-Null}
                Games
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                if($winget_programs.Contains("Ubisoft.Connect")){$winget_programs.Remove("Ubisoft.Connect")} else {$winget_programs.Add("Ubisoft.Connect") | Out-Null}
                Games
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Games"
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Mobile_Emulators{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Мобильные эмуляторы"} else {"Mobile Emulators"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("BlueStack.BlueStacks")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) BlueStacks `n"
    Write-Host "                  $(if($winget_programs.Contains("Genymobile.Genymotion")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Genymotion `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("BlueStack.BlueStacks")){$winget_programs.Remove("BlueStack.BlueStacks")} else {$winget_programs.Add("BlueStack.BlueStacks") | Out-Null}
                Mobile_Emulators
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Genymobile.Genymotion")){$winget_programs.Remove("Genymobile.Genymotion")} else {$winget_programs.Add("Genymobile.Genymotion") | Out-Null}
                Mobile_Emulators
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Mobile_Emulators"
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Other_Emulators{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Другие эмуляторы"} else {"Other Emulators"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("Libretro.RetroArch")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) RetroArch `n"
    Write-Host "                  $(if($winget_programs.Contains("DOSBox.DOSBox")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) DOSBox `n"
    Write-Host "                  $(if($winget_programs.Contains("PPSSPPTeam.PPSSPP")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) PPSSPP `n"
    Write-Host "                  $(if($winget_programs.Contains("DolphinEmulator.Dolphin")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Dolphin `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Libretro.RetroArch")){$winget_programs.Remove("Libretro.RetroArch")} else {$winget_programs.Add("Libretro.RetroArch") | Out-Null}
                Other_Emulators
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("DOSBox.DOSBox")){$winget_programs.Remove("DOSBox.DOSBox")} else {$winget_programs.Add("DOSBox.DOSBox") | Out-Null}
                Other_Emulators
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("PPSSPPTeam.PPSSPP")){$winget_programs.Remove("PPSSPPTeam.PPSSPP")} else {$winget_programs.Add("PPSSPPTeam.PPSSPP") | Out-Null}
                Other_Emulators
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("DolphinEmulator.Dolphin")){$winget_programs.Remove("DolphinEmulator.Dolphin")} else {$winget_programs.Add("DolphinEmulator.Dolphin") | Out-Null}
                Other_Emulators
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Other_Emulators"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Graphics_Tools{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Графические редакторы"} else {"Graphics Tools"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("GIMP.GIMP")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) GIMP `n"
    Write-Host "                  $(if($winget_programs.Contains("Inkscape.Inkscape")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Inkscape `n"
    Write-Host "                  $(if($winget_programs.Contains("KDE.Krita")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Krita `n"
    Write-Host "                  $(if($winget_programs.Contains("Figma.Figma")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Figma `n"
    Write-Host "                  $(if($winget_programs.Contains("dotPDN.PaintDotNet")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Paint.NET `n"
    Write-Host "                  $(if($winget_programs.Contains("Toinane.Colorpicker")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) Colorpicker `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("GIMP.GIMP")){$winget_programs.Remove("GIMP.GIMP")} else {$winget_programs.Add("GIMP.GIMP") | Out-Null}
                Graphics_Tools
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Inkscape.Inkscape")){$winget_programs.Remove("Inkscape.Inkscape")} else {$winget_programs.Add("Inkscape.Inkscape") | Out-Null}
                Graphics_Tools
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("KDE.Krita")){$winget_programs.Remove("KDE.Krita")} else {$winget_programs.Add("KDE.Krita") | Out-Null}
                Graphics_Tools
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("Figma.Figma")){$winget_programs.Remove("Figma.Figma")} else {$winget_programs.Add("Figma.Figma") | Out-Null}
                Graphics_Tools
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("dotPDN.PaintDotNet")){$winget_programs.Remove("dotPDN.PaintDotNet")} else {$winget_programs.Add("dotPDN.PaintDotNet") | Out-Null}
                Graphics_Tools
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("Toinane.Colorpicker")){$winget_programs.Remove("Toinane.Colorpicker")} else {$winget_programs.Add("Toinane.Colorpicker") | Out-Null}
                Graphics_Tools
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Graphics_Tools"
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7")) -or ($choice -eq "Escape")) #Выход из цикла
}

function 3D_Modeling_and_Animation{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"3D моделирование и анимация"} else {"3D Modeling and Animation"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("BlenderFoundation.Blender")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Blender `n"
    Write-Host "                  $(if($winget_programs.Contains("FreeCAD.FreeCAD")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) FreeCAD `n"
    Write-Host "                  $(if($winget_programs.Contains("OpenSCAD.OpenSCAD")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) OpenSCAD `n"
    Write-Host "                  $(if($winget_programs.Contains("Wings3D.Wings3D")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Wings 3D `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("BlenderFoundation.Blender")){$winget_programs.Remove("BlenderFoundation.Blender")} else {$winget_programs.Add("BlenderFoundation.Blender") | Out-Null}
                3D_Modeling_and_Animation
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("FreeCAD.FreeCAD")){$winget_programs.Remove("FreeCAD.FreeCAD")} else {$winget_programs.Add("FreeCAD.FreeCAD") | Out-Null}
                3D_Modeling_and_Animation
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("OpenSCAD.OpenSCAD")){$winget_programs.Remove("OpenSCAD.OpenSCAD")} else {$winget_programs.Add("OpenSCAD.OpenSCAD") | Out-Null}
                3D_Modeling_and_Animation
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("Wings3D.Wings3D")){$winget_programs.Remove("ElectronicArts.EADesktop")} else {$winget_programs.Add("Wings3D.Wings3D") | Out-Null}
                3D_Modeling_and_Animation
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "3D_Modeling_and_Animation"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Image_Viewers{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Просмотр изображений"} else {"Image Viewers"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("DuongDieuPhap.ImageGlass")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) ImageGlass `n"
    Write-Host "                  $(if($winget_programs.Contains("IrfanSkiljan.IrfanView")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Irfanview `n"
    Write-Host "                  $(if($winget_programs.Contains("sylikc.JPEGView")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) JPEGView `n"
    Write-Host "                  $(if($winget_programs.Contains("jurplel.qView")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) qView `n"
    Write-Host "                  $(if($winget_programs.Contains("XnSoft.XnView.Classic")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) XnView `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("DuongDieuPhap.ImageGlass")){$winget_programs.Remove("DuongDieuPhap.ImageGlass")} else {$winget_programs.Add("DuongDieuPhap.ImageGlass") | Out-Null}
                Image_Viewers
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("IrfanSkiljan.IrfanView")){$winget_programs.Remove("IrfanSkiljan.IrfanView")} else {$winget_programs.Add("IrfanSkiljan.IrfanView") | Out-Null}
                Image_Viewers
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("sylikc.JPEGView")){$winget_programs.Remove("sylikc.JPEGView")} else {$winget_programs.Add("sylikc.JPEGView") | Out-Null}
                Image_Viewers
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("jurplel.qView")){$winget_programs.Remove("jurplel.qView")} else {$winget_programs.Add("jurplel.qView") | Out-Null}
                Image_Viewers
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("XnSoft.XnView.Classic")){$winget_programs.Remove("XnSoft.XnView.Classic")} else {$winget_programs.Add("XnSoft.XnView.Classic") | Out-Null}
                Image_Viewers
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Image_Viewers"
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){Main-page-two}
            if ($choice -eq "Escape"){Main-page-two}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Remote_Access{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Удалённый доступ"} else {"Remote Access"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("AnyDeskSoftwareGmbH.AnyDesk")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) AnyDesk `n"
    Write-Host "                  $(if($winget_programs.Contains("MoonlightGameStreamingProject.Moonlight")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Moonlight `n"
    Write-Host "                  $(if($winget_programs.Contains("Parsec.Parsec")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Parsec `n"
    Write-Host "                  $(if($winget_programs.Contains("RustDesk.RustDesk")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) RustDesk `n"
    Write-Host "                  $(if($winget_programs.Contains("Valve.SteamLink")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Steam Link `n"
    Write-Host "                  $(if($winget_programs.Contains("TeamViewer.TeamViewer")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) TeamViewer `n"
    Write-Host "                  $(if($winget_programs.Contains("Microsoft.RemoteDesktopClient")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Windows Remote Desktop `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("AnyDeskSoftwareGmbH.AnyDesk")){$winget_programs.Remove("AnyDeskSoftwareGmbH.AnyDesk")} else {$winget_programs.Add("AnyDeskSoftwareGmbH.AnyDesk") | Out-Null}
                Remote_Access
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("MoonlightGameStreamingProject.Moonlight")){$winget_programs.Remove("MoonlightGameStreamingProject.Moonlight")} else {$winget_programs.Add("MoonlightGameStreamingProject.Moonlight") | Out-Null}
                Remote_Access
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Parsec.Parsec")){$winget_programs.Remove("Parsec.Parsec")} else {$winget_programs.Add("Parsec.Parsec") | Out-Null}
                Remote_Access
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("RustDesk.RustDesk")){$winget_programs.Remove("RustDesk.RustDesk")} else {$winget_programs.Add("RustDesk.RustDesk") | Out-Null}
                Remote_Access
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("Valve.SteamLink")){$winget_programs.Remove("Valve.SteamLink")} else {$winget_programs.Add("Valve.SteamLink") | Out-Null}
                Remote_Access
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("TeamViewer.TeamViewer")){$winget_programs.Remove("TeamViewer.TeamViewer")} else {$winget_programs.Add("TeamViewer.TeamViewer") | Out-Null}
                Remote_Access
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("Microsoft.RemoteDesktopClient")){$winget_programs.Remove("Microsoft.RemoteDesktopClient")} else {$winget_programs.Add("Microsoft.RemoteDesktopClient") | Out-Null}
                Remote_Access
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Remote_Access"
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){Main-page-three}
            if ($choice -eq "Escape"){Main-page-three}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or ($choice -eq "Escape")) #Выход из цикла
}

function VPN_and_Proxy_Tools{


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"VPN и Прокси"} else {"VPN and Proxy"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  $(if($winget_programs.Contains("MatsuriDayo.NekoRay")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Neko Ray `n"
    Write-Host "                  $(if($winget_programs.Contains("Hiddify.Next")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Hiddify `n"
    Write-Host "                  $(if($winget_programs.Contains("OpenVPNTechnologies.OpenVPN")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) OpenVPN `n"
    Write-Host "                  $(if($winget_programs.Contains("WireGuard.WireGuard")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) WireGuard `n"
    Write-Host "                  $(if($winget_programs.Contains("SagerNet.sing-box")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Sing-box `n"
    Write-Host "                  $(if($winget_programs.Contains("2dust.v2rayN")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) v2rayN `n"
    Write-Host "                  $(if($winget_programs.Contains("Cloudflare.Warp")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Cloudflare WARP `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})`n`n`n"
    

    do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("MatsuriDayo.NekoRay")){$winget_programs.Remove("MatsuriDayo.NekoRay")} else {$winget_programs.Add("MatsuriDayo.NekoRay") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Hiddify.Next")){$winget_programs.Remove("Hiddify.Next")} else {$winget_programs.Add("Hiddify.Next") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("OpenVPNTechnologies.OpenVPN")){$winget_programs.Remove("OpenVPNTechnologies.OpenVPN")} else {$winget_programs.Add("OpenVPNTechnologies.OpenVPN") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("WireGuard.WireGuard")){$winget_programs.Remove("WireGuard.WireGuard")} else {$winget_programs.Add("WireGuard.WireGuard") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("SagerNet.sing-box")){$winget_programs.Remove("SagerNet.sing-box")} else {$winget_programs.Add("SagerNet.sing-box") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains("2dust.v2rayN")){$winget_programs.Remove("2dust.v2rayN")} else {$winget_programs.Add("2dust.v2rayN") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains("Cloudflare.Warp")){$winget_programs.Remove("Cloudflare.Warp")} else {$winget_programs.Add("Cloudflare.Warp") | Out-Null}
                VPN_and_Proxy_Tools
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "VPN_and_Proxy_Tools"
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){Main-page-three}
            if ($choice -eq "Escape"){Main-page-three}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Video{

    function Video_Editors{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Видео >> Видеоредакторы"} else {"Video >> Video Editors"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Meltytech.Shotcut")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Shotcut `n"
        Write-Host "                  $(if($winget_programs.Contains("OpenShot.OpenShot")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) OpenShot `n"
        Write-Host "                  $(if($winget_programs.Contains("LWKS.lightworks")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Lightworks `n"
        Write-Host "                  $(if($winget_programs.Contains("VSDC.Editor")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) VSDC Free Video Editor `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("Meltytech.Shotcut")){$winget_programs.Remove("Meltytech.Shotcut")} else {$winget_programs.Add("Meltytech.Shotcut") | Out-Null}
               Video_Editors
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("OpenShot.OpenShot")){$winget_programs.Remove("OpenShot.OpenShot")} else {$winget_programs.Add("OpenShot.OpenShot") | Out-Null}
               Video_Editors
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("LWKS.lightworks")){$winget_programs.Remove("LWKS.lightworks")} else {$winget_programs.Add("LWKS.lightworks") | Out-Null}
               Video_Editors
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("VSDC.Editor")){$winget_programs.Remove("VSDC.Editor")} else {$winget_programs.Add("VSDC.Editor") | Out-Null}
               Video_Editors
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Video_Editors"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Video}
            if ($choice -eq "Escape"){Video}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Video_Players{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Видео >> Видеоплееры"} else {"Video >>  Video Players"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("VideoLAN.VLC")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) VLC Media Player `n"
        Write-Host "                  $(if($winget_programs.Contains("Daum.PotPlayer")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) PotPlayer `n"
        Write-Host "                  $(if($winget_programs.Contains("XBMCFoundation.Kodi")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Kodi `n"
        Write-Host "                  $(if($winget_programs.Contains("NickeManarin.ScreenToGif")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) ScreenToGif `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("VideoLAN.VLC")){$winget_programs.Remove("VideoLAN.VLC")} else {$winget_programs.Add("VideoLAN.VLC") | Out-Null}
                Video_Players
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Daum.PotPlayer")){$winget_programs.Remove("Daum.PotPlayer")} else {$winget_programs.Add("Daum.PotPlayer") | Out-Null}
                Video_Players
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("XBMCFoundation.Kodi")){$winget_programs.Remove("XBMCFoundation.Kodi")} else {$winget_programs.Add("XBMCFoundation.Kodi") | Out-Null}
                Video_Players
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("NickeManarin.ScreenToGif")){$winget_programs.Remove("NickeManarin.ScreenToGif")} else {$winget_programs.Add("NickeManarin.ScreenToGif") | Out-Null}
                Video_Players
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Video_Players"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Video}
            if ($choice -eq "Escape"){Video}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Video_Streaming_and_Recording{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Видео >> Стриминг и запись"} else {"Video >>  Video Streaming and Recording"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("OBSProject.OBSStudio")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) OBS Studio `n"
        Write-Host "                  $(if($winget_programs.Contains("Jitsi.Meet")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Jitsi Meet `n"
        Write-Host "                  $(if($winget_programs.Contains("Zoom.Zoom")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Zoom `n"
        Write-Host "                  $(if($winget_programs.Contains("Streamlabs.Streamlabs")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Streamlabs Desktop `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("OBSProject.OBSStudio")){$winget_programs.Remove("OBSProject.OBSStudio")} else {$winget_programs.Add("OBSProject.OBSStudio") | Out-Null}
                Video_Streaming_and_Recording
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("Jitsi.Meet")){$winget_programs.Remove("Jitsi.Meet")} else {$winget_programs.Add("Jitsi.Meet") | Out-Null}
                Video_Streaming_and_Recording
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("Zoom.Zoom")){$winget_programs.Remove("Zoom.Zoom")} else {$winget_programs.Add("Zoom.Zoom") | Out-Null}
                Video_Streaming_and_Recording
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("Streamlabs.Streamlabs")){$winget_programs.Remove("Streamlabs.Streamlabs")} else {$winget_programs.Add("Streamlabs.Streamlabs") | Out-Null}
                Video_Streaming_and_Recording
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Video_Streaming_and_Recording"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Video}
            if ($choice -eq "Escape"){Video}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Video_Converters_and_Compressors{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Видео >> Видео конверторы и компрессоры"} else {"Video >>  Video Converters and Compressors"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("Gyan.FFmpeg")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) FFmpeg `n"
        Write-Host "                  $(if($winget_programs.Contains("XMediaRecode.XMediaRecode")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) XMedia Recode `n"
        Write-Host "                  $(if($winget_programs.Contains("RandomEngy.VidCoder")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) VidCoder `n"
        Write-Host "                  $(if($winget_programs.Contains("HandBrake.HandBrake")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) HandBrake `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("Gyan.FFmpeg")){$winget_programs.Remove("Gyan.FFmpeg")} else {$winget_programs.Add("Gyan.FFmpeg") | Out-Null}
                Video_Converters_and_Compressors
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("XMediaRecode.XMediaRecode")){$winget_programs.Remove("XMediaRecode.XMediaRecode")} else {$winget_programs.Add("XMediaRecode.XMediaRecode") | Out-Null}
                Video_Converters_and_Compressors
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("RandomEngy.VidCoder")){$winget_programs.Remove("RandomEngy.VidCoder")} else {$winget_programs.Add("RandomEngy.VidCoder") | Out-Null}
                Video_Converters_and_Compressors
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("HandBrake.HandBrake")){$winget_programs.Remove("HandBrake.HandBrake")} else {$winget_programs.Add("HandBrake.HandBrake") | Out-Null}
                Video_Converters_and_Compressors
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Video_Converters_and_Compressors"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Video}
            if ($choice -eq "Escape"){Video}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Видео"} else {"Video"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Видеоредакторы\"} else {"Video Editors\"}) `n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Видеоплееры\"} else {"Video Players\"}) `n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Стриминг и запись\"} else {"Video Streaming and Recording\"}) `n"
    Write-Host "                  [4] $(if($Menu_Lang -eq "ru-Ru"){"Видео конверторы и компрессоры\"} else {"Video Converters and Compressors\"}) `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               Video_Editors
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               Video_Players
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               Video_Streaming_and_Recording
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               Video_Converters_and_Compressors
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Video"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Main-page-three}
            if ($choice -eq "Escape"){Main-page-three}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Utility{

    function Metadata{
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Утилиты >> Метаданные"} else {"Utility >> Metadata"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("OliverBetz.ExifTool")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) ExifTool `n"
        Write-Host "                  $(if($winget_programs.Contains("FlorianHeidenreich.Mp3tag")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) MP3Tag `n"
        Write-Host "                  $(if($winget_programs.Contains("MiTeC.HexEdit")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) HexEdit `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               if($winget_programs.Contains("OliverBetz.ExifTool")){$winget_programs.Remove("OliverBetz.ExifTool")} else {$winget_programs.Add("OliverBetz.ExifTool") | Out-Null}
               Metadata
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               if($winget_programs.Contains("FlorianHeidenreich.Mp3tag")){$winget_programs.Remove("FlorianHeidenreich.Mp3tag")} else {$winget_programs.Add("FlorianHeidenreich.Mp3tag") | Out-Null}
               Metadata
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               if($winget_programs.Contains("MiTeC.HexEdit")){$winget_programs.Remove("MiTeC.HexEdit")} else {$winget_programs.Add("MiTeC.HexEdit") | Out-Null}
               Metadata
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Metadata"
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){Utility}
            if ($choice -eq "Escape"){Utility}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function File_Management{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Утилиты >> Управление файлами"} else {"Utility >>  File Management"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("voidtools.Everything")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Everything `n"
        Write-Host "                  $(if($winget_programs.Contains("WinSCP.WinSCP")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) WinSCP `n"
        Write-Host "                  $(if($winget_programs.Contains("FarManager.FarManager")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) Far Manager `n"
        Write-Host "                  $(if($winget_programs.Contains("Bopsoft.Listary")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Listary `n"
        Write-Host "                  $(if($winget_programs.Contains("alexx2000.DoubleCommander")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Double Commander `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("voidtools.Everything")){$winget_programs.Remove("voidtools.Everything")} else {$winget_programs.Add("voidtools.Everything") | Out-Null}
                File_Management
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("WinSCP.WinSCP")){$winget_programs.Remove("WinSCP.WinSCP")} else {$winget_programs.Add("WinSCP.WinSCP") | Out-Null}
                File_Management
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("FarManager.FarManager")){$winget_programs.Remove("FarManager.FarManager")} else {$winget_programs.Add("FarManager.FarManager") | Out-Null}
                File_Management
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("Bopsoft.Listary")){$winget_programs.Remove("Bopsoft.Listary")} else {$winget_programs.Add("Bopsoft.Listary") | Out-Null}
                File_Management
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains("alexx2000.DoubleCommander")){$winget_programs.Remove("alexx2000.DoubleCommander")} else {$winget_programs.Add("alexx2000.DoubleCommander") | Out-Null}
                File_Management
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "File_Management"
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){Utility}
            if ($choice -eq "Escape"){Utility}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }

    function Space_Visualizer{

        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Утилиты >> Визуализаторы файлового пространства"} else {"Utility >> Space Visualizer"})"
        Write-Host ""
        Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
        Write-Host ""
        Write-Host "                  $(if($winget_programs.Contains("UderzoSoftware.SpaceSniffer")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) SpaceSniffer `n"
        Write-Host "                  $(if($winget_programs.Contains("AntibodySoftware.WizTree")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) WizTree `n"
        Write-Host "                  $(if($winget_programs.Contains("JAMSoftware.TreeSize")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) TreeSize `n"
        Write-Host "                  $(if($winget_programs.Contains("KDE.Filelight")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) Filelight `n"
        Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


        do {
            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains("UderzoSoftware.SpaceSniffer")){$winget_programs.Remove("UderzoSoftware.SpaceSniffer")} else {$winget_programs.Add("UderzoSoftware.SpaceSniffer") | Out-Null}
                Space_Visualizer
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains("AntibodySoftware.WizTree")){$winget_programs.Remove("AntibodySoftware.WizTree")} else {$winget_programs.Add("AntibodySoftware.WizTree") | Out-Null}
                Space_Visualizer
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains("JAMSoftware.TreeSize")){$winget_programs.Remove("JAMSoftware.TreeSize")} else {$winget_programs.Add("JAMSoftware.TreeSize") | Out-Null}
                Space_Visualizer
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains("KDE.Filelight")){$winget_programs.Remove("KDE.Filelight")} else {$winget_programs.Add("KDE.Filelight") | Out-Null}
                Space_Visualizer
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Space_Visualizer"
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){Utility}
            if ($choice -eq "Escape"){Utility}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or ($choice -eq "Escape")) #Выход из цикла
    }


    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Утилиты"} else {"Utility"})"
    Write-Host ""
    Center-Text "[F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Метаданные\"} else {"Metadata\"}) `n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Управление файлами\"} else {"File Management\"}) `n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Визуализаторы файлового пространства\"} else {"Space Visualizer\"}) `n"
    Write-Host "                  $(if($winget_programs.Contains("Microsoft.PowerToys")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) PowerToys `n"
    Write-Host "                  $(if($winget_programs.Contains("PuTTY.PuTTY")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) PuTTY `n"
    Write-Host "                  $(if($winget_programs.Contains("AutoHotkey.AutoHotkey")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) AutoHotkey `n"
    Write-Host "                  $(if($winget_programs.Contains("Famatech.AdvancedIPScanner")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Advanced IP Scanner `n"
    Write-Host "                  $(if($winget_programs.Contains("Guru3D.Afterburner")) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) MSI Afterburner `n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
               Metadata
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
               File_Management
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
               Space_Visualizer
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
               if($winget_programs.Contains("Microsoft.PowerToys")){$winget_programs.Remove("Microsoft.PowerToys")} else {$winget_programs.Add("Microsoft.PowerToys") | Out-Null}
                Utility
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
               if($winget_programs.Contains("PuTTY.PuTTY")){$winget_programs.Remove("PuTTY.PuTTY")} else {$winget_programs.Add("PuTTY.PuTTY") | Out-Null}
                Utility
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
               if($winget_programs.Contains("AutoHotkey.AutoHotkey")){$winget_programs.Remove("AutoHotkey.AutoHotkey")} else {$winget_programs.Add("AutoHotkey.AutoHotkey") | Out-Null}
                Utility
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
               if($winget_programs.Contains("Famatech.AdvancedIPScanner")){$winget_programs.Remove("Famatech.AdvancedIPScanner")} else {$winget_programs.Add("Famatech.AdvancedIPScanner") | Out-Null}
                Utility
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
               if($winget_programs.Contains("Guru3D.Afterburner")){$winget_programs.Remove("Guru3D.Afterburner")} else {$winget_programs.Add("Guru3D.Afterburner") | Out-Null}
                Utility
            }
            if ($choice -eq "F2"){
	            programs_print -exit_to "Utility"
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Main-page-three}
            if ($choice -eq "Escape"){Main-page-three}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Config{
    Draw-Banner
    Write-Host "`n`n`n`n"
    Center-Text "[1]$(if($Menu_Lang -eq "ru-Ru"){"Загрузить"} else {"Load"})   [2]$(if($Menu_Lang -eq "ru-Ru"){"Сохранить"} else {"Save"})"
    Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
    Center-Text "[Esc]$(if($Menu_Lang -eq "ru-Ru"){"Выход"} else {"Exit"})"

    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                $selectedFile = Select-File
                if ($selectedFile -eq $null) {Config}
                Draw-Banner
                Manage_WingetPrograms -FilePath $selectedFile -Mode "read"
                Write-Host "`n"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Загружены:"} else {"Loaded:"})"
                Write-Host "`n"
                Print-Programs -programs $winget_programs -maxWidth 120
                Write-Host "`n"
                pause
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                $cfg_file = Folder-choose -default $false
                if ($cfg_file -eq $null){Config}
                $selectedFile = Join-Path $cfg_file "BURAN_config.json"
                Manage_WingetPrograms -FilePath $selectedFile -Mode "write"
                Draw-Banner
                Write-Host "`n"
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Конфиг сохранён!"} else {"Config saved!"})"
                Write-Host "`n"
                pause
        }
        if ($choice -eq "Escape"){Main-menu}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or ($choice -eq "Escape"))

    
    




    Main-menu
}

function Search{
    if ($s_word -eq $null) {
        Draw-Banner
        Write-Host "                                              $(if($Menu_Lang -eq "ru-Ru"){"Введите название приложения: "} else {"   Enter programm name: "})" -NoNewline
        $s_word = Read-Host
        winget_search -Search_Word $s_word
    }


    Draw-Banner
    if ($global:id[0] -ne $null) {Write-Host "                  $(if($Menu_Lang -eq "ru-Ru"){"    Название:"} else {"    Name:    "})                                        $(if($Menu_Lang -eq "ru-Ru"){"Айди:"} else {"Id:"})`n"} else {
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Ничего не найдено!"} else {"Nothing was found!"})"
        Write-Host " "
    }
    if ($global:id[0] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[0])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) $($global:names[0])$(add_space -name_space $global:names[0])$($global:id[0])`n" }
    if ($global:id[1] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[1])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) $($global:names[1])$(add_space -name_space $global:names[1])$($global:id[1])`n"}
    if ($global:id[2] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[2])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) $($global:names[2])$(add_space -name_space $global:names[2])$($global:id[2])`n"}
    if ($global:id[3] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[3])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) $($global:names[3])$(add_space -name_space $global:names[3])$($global:id[3])`n"}
    if ($global:id[4] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[4])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) $($global:names[4])$(add_space -name_space $global:names[4])$($global:id[4])`n"}
    if ($global:id[5] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[5])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) $($global:names[5])$(add_space -name_space $global:names[5])$($global:id[5])`n"}
    if ($global:id[6] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[6])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) $($global:names[6])$(add_space -name_space $global:names[6])$($global:id[6])`n"}
    if ($global:id[7] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[7])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) $($global:names[7])$(add_space -name_space $global:names[7])$($global:id[7])`n"}
    if ($global:id[8] -ne $null) {Write-Host "                  $(if($winget_programs.Contains($global:id[8])) {"$([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[9]"}) $($global:names[8])$(add_space -name_space $global:names[8])$($global:id[8])`n`n`n"}
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[Esc] Выход"} else {"[Esc] Exit"})"


    do {
            $choice = [Console]::ReadKey($true).Key            #считывание нажатия
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($winget_programs.Contains($global:id[0])){$winget_programs.Remove($global:id[0])} else {$winget_programs.Add($global:id[0]) | Out-Null}
               Search
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($winget_programs.Contains($global:id[1])){$winget_programs.Remove($global:id[1])} else {$winget_programs.Add($global:id[1]) | Out-Null}
               Search
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($winget_programs.Contains($global:id[2])){$winget_programs.Remove($global:id[2])} else {$winget_programs.Add($global:id[2]) | Out-Null}
               Search
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($winget_programs.Contains($global:id[3])){$winget_programs.Remove($global:id[3])} else {$winget_programs.Add($global:id[3]) | Out-Null}
               Search
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($winget_programs.Contains($global:id[4])){$winget_programs.Remove($global:id[4])} else {$winget_programs.Add($global:id[4]) | Out-Null}
               Search
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($winget_programs.Contains($global:id[5])){$winget_programs.Remove($global:id[5])} else {$winget_programs.Add($global:id[5]) | Out-Null}
               Search
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($winget_programs.Contains($global:id[6])){$winget_programs.Remove($global:id[6])} else {$winget_programs.Add($global:id[6]) | Out-Null}
               Search
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                if($winget_programs.Contains($global:id[7])){$winget_programs.Remove($global:id[7])} else {$winget_programs.Add($global:id[7]) | Out-Null}
               Search
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){
                if($winget_programs.Contains($global:id[8])){$winget_programs.Remove($global:id[8])} else {$winget_programs.Add($global:id[8]) | Out-Null}
               Search
            }
            if ($choice -eq "Escape"){
                $s_word = $null
                Main-menu
            }
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "Escape")) #Выход из цикла
}
#








#Основные страницы
function Main-page-three {
    Draw-Banner
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Удалённый доступ\"} else {"Remote Access\"})`n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"VPN и Прокси\"} else {"VPN and Proxy\"})`n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Видео\"} else {"Video\"})`n"
    Write-Host "                  [4] $(if($Menu_Lang -eq "ru-Ru"){"Утилиты\"} else {"Utility\"})`n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"
    Write-Host "`n`n`n`n`n`n`n`n`n`n"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Установить"} else {"[Space] - Install"})   [F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Страница 3"} else {"Page 3"})"
    Write-Host "                                                   <- [A]"



    do {
            $choice = [Console]::ReadKey($true).Key            #считывание нажатия
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                Remote_Access
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                VPN_and_Proxy_Tools
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                Video
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                Utility
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Main-menu}
            if ($choice -eq "Spacebar"){
                installation
            }
            if (($choice -eq "F2") -or ($choice -eq "NumPad2")){
                programs_print -exit_to "Main-page-three"
            }
            if ($choice -eq "A"){Main-page-two}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "A") -or ($choice -eq "Escape")) #Выход из цикла
}

function Main-page-two {
    Draw-Banner
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Документы\"} else {"Documents\"})`n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Текстовые редакторы\"} else {"Text Editors\"})`n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Игровые лаунчеры\"} else {"Games launchers\"})`n"
    Write-Host "                  [4] $(if($Menu_Lang -eq "ru-Ru"){"Мобильные эмуляторы\"} else {"Mobile Emulators\"})`n"
    Write-Host "                  [5] $(if($Menu_Lang -eq "ru-Ru"){"Другие эмуляторы\"} else {"Other Emulators\"})`n"
    Write-Host "                  [6] $(if($Menu_Lang -eq "ru-Ru"){"Графические редакторы\"} else {"Graphics Tools\"})`n"
    Write-Host "                  [7] $(if($Menu_Lang -eq "ru-Ru"){"3D моделирование и анимация\"} else {"3D Modeling and Animation\"})`n"
    Write-Host "                  [8] $(if($Menu_Lang -eq "ru-Ru"){"Просмотр изображений\"} else {"Image Viewers\"})`n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mНазад$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack$([char]27)[0m"})"
    Write-Host "`n`n"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Установить"} else {"[Space] - Install"})   [F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов"} else {"List of packages"})"
    Write-Host ""
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Страница 2"} else {"Page 2"})"
    Center-Text "<- [A]      [D] ->"



    do {
            $choice = [Console]::ReadKey($true).Key            #считывание нажатия
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                Documents
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                Text_Editors
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                Games
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                Mobile_Emulators
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                Other_Emulators
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                Graphics_Tools
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                3D_Modeling_and_Animation
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                Image_Viewers
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){Main-menu}
            if ($choice -eq "Spacebar"){
                installation
            }
            if (($choice -eq "F2") -or ($choice -eq "NumPad2")){
                programs_print -exit_to "Main-page-two"
            }
            if ($choice -eq "A"){Main-menu}
            if ($choice -eq "D"){Main-page-three}
            if ($choice -eq "Escape"){Main-menu}
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "A") -or ($choice -eq "D") -or ($choice -eq "Escape")) #Выход из цикла
}

function Main-menu {
    Draw-Banner
    Write-Host "                  [F1] $(if($Menu_Lang -eq "ru-Ru"){"Обновить все установленные программы"} else {"Upgrade all installed programs"})                  $(if($Menu_Lang -eq "ru-Ru"){"   [F3] Поиск"} else {"          [F3] Search"})`n"
    Write-Host "                  [F2] $(if($Menu_Lang -eq "ru-Ru"){"Список пакетов которые будут установлены"} else {"List of packages that will be installed"})          $(if($Menu_Lang -eq "ru-Ru"){"       [Tab] Загрузить/Сохранить конфиг"} else {"         [Tab] Load/Save config"})`n"
    Write-Host "                  $(if($Menu_Lang -eq "ru-Ru"){"---------"})-------------------------------------------------------------------------------------`n"
    Write-Host "                  [1] $(if($Menu_Lang -eq "ru-Ru"){"Звук\"} else {"Audio\"})`n"
    Write-Host "                  [2] $(if($Menu_Lang -eq "ru-Ru"){"Браузеры\"} else {"Browsers\"})$([char]27)[24m`n"
    Write-Host "                  [3] $(if($Menu_Lang -eq "ru-Ru"){"Общение\"} else {"Communication\"})`n"
    Write-Host "                  [4] $(if($Menu_Lang -eq "ru-Ru"){"Сжатие и Архивирование\"} else {"Compression and Archiving\"})`n"
    Write-Host "                  [5] $(if($Menu_Lang -eq "ru-Ru"){"Кастомизация\"} else {"Customize\"})`n"
    Write-Host "                  [6] $(if($Menu_Lang -eq "ru-Ru"){"Инструменты для разработки\"} else {"Developer Tools\"})`n"
    Write-Host "                  $([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m $(if($Menu_Lang -eq "ru-Ru"){"$([char]27)[48;5;2m$([char]27)[38;5;0mВыход в меню$([char]27)[0m"} else {"$([char]27)[48;5;2m$([char]27)[38;5;0mBack to menu$([char]27)[0m"})"
    Write-Host ""
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"[Пробел] - Установить"} else {"[Space] - Install"})"
    Write-Host ""
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Страница 1"} else {"Page 1"})"
    Center-Text "            [D] ->"


    do {
            $choice = [Console]::ReadKey($true).Key
            #Write-Host "Вы нажали: $choice"
            if (($choice -eq "F1") -or ($choice -eq "NumPad1")){
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Вы точно хотите обновить все установленные приложения?"} else {"Are you sure you want to update all the installed apps?"})`n"
                Center-Text "[1] $(if($Menu_Lang -eq "ru-Ru"){"Да"} else {"Yes"})   [2] $(if($Menu_Lang -eq "ru-Ru"){"Нет"} else {"No"})"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                        Draw-Banner -Text_Color "White" -Background_Color "DarkMagenta" -Clear "1"
                        Set-ConsoleColor "DarkMagenta" "White"
                        winget upgrade --all
                        Write-Host ""
                        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})"
                        pause
                        Main-menu
                    }
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        Main-menu
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
            }
            if (($choice -eq "F2") -or ($choice -eq "NumPad2")){
                programs_print -exit_to "Main-menu"
            }
            if (($choice -eq "D1") -or ($choice -eq "NumPad3")){
                Audio
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad4")){
                Browsers
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad5")){
                Communication
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad6")){
                Compression_and_Archiving
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad7")){
                Customize
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad8")){
                Developer_Tools
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad9")){
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Вы точно хотите выйти?"} else {"Are you sure you want exit?"})`n"
                Center-Text "[1] $(if($Menu_Lang -eq "ru-Ru"){"Да"} else {"Yes"})   [2] $(if($Menu_Lang -eq "ru-Ru"){"Нет"} else {"No"})"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                        Goto-main
                    }
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        Main-menu
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
            }
            if ($choice -eq "Spacebar") {installation}
            if ($choice -eq "D"){Main-page-two}
            if ($choice -eq "Escape"){
                Draw-Banner
                Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Вы точно хотите выйти?"} else {"Are you sure you want exit?"})`n"
                Center-Text "[1] $(if($Menu_Lang -eq "ru-Ru"){"Да"} else {"Yes"})   [2] $(if($Menu_Lang -eq "ru-Ru"){"Нет"} else {"No"})"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                        Goto-main
                    }
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        Main-menu
                    }
                    if ($choice -eq "Escape"){
                        Main-menu
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
            }
            if ($choice -eq "Tab"){
                Config
            }
            if ($choice -eq "F3"){
                Search
            }
            if (($choice -eq "Delete") -and ($Debug -eq $true)){
                if ($winget_programs.Count -eq 0){Write-Host "Empty"} else {$winget_programs}   
            }
        } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3"))-or (($choice -eq "D4") -or ($choice -eq "NumPad4"))-or (($choice -eq "D5") -or ($choice -eq "NumPad5"))-or (($choice -eq "D6") -or ($choice -eq "NumPad6"))-or (($choice -eq "D7") -or ($choice -eq "NumPad7"))-or (($choice -eq "D8") -or ($choice -eq "NumPad8"))-or (($choice -eq "D9") -or ($choice -eq "NumPad9")) -or ($choice -eq "D") -or ($choice -eq "Escape")) #Выход из цикла
}





#Начало
Winget-Check
pause
