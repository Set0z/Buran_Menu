#Тут описаны подключаемые модули
$ver= $env:version
$scstate = $env:script_state
#Функция возвращения в главное меню
function Goto-main {
    if ($scstate -eq "Internet"){irm "https://raw.githubusercontent.com/Set0z/Buran_Menu/refs/heads/main/modules/script.ps1" | iex} else {
        $filePath = Join-Path -Path $scriptDir -ChildPath 'script.ps1'
        Start-Process "powershell.exe" -ArgumentList @("-File `"$filePath`"") -Verb RunAs
        exit
    }
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
        [string]$Clear = 1,
        [string]$Text_After_Color = "Green",
        [string]$Background_After_Color = "Black"
    )
    Set-ConsoleColor $Background_Color $Text_Color  $Clear
    Write-Host "`n"
    Center-Text " ███████████     █████  █████    ███████████        █████████      ██████   █████   "
    Center-Text "░░███░░░░░███   ░░███  ░░███    ░░███░░░░░███      ███░░░░░███    ░░██████ ░░███    "
    Center-Text " ░███    ░███    ░███   ░███     ░███    ░███     ░███    ░███     ░███░███ ░███    "
    Center-Text " ░██████████     ░███   ░███     ░██████████      ░███████████     ░███░░███░███    "
    Center-Text " ░███░░░░░███    ░███   ░███     ░███░░░░░███     ░███░░░░░███     ░███ ░░██████    "
    Center-Text " ░███    ░███    ░███   ░███     ░███    ░███     ░███    ░███     ░███  ░░█████    "
    Center-Text " ███████████  ██ ░░████████   ██ █████   █████ ██ █████   █████ ██ █████  ░░█████ ██"
    Center-Text "░░░░░░░░░░░  ░░   ░░░░░░░░   ░░ ░░░░░   ░░░░░ ░░ ░░░░░   ░░░░░ ░░ ░░░░░    ░░░░░ ░░ "
    Write-Host "`n"          
    Center-Text "               ██████   ██████ ██████████ ██████   █████ █████  █████               "
    Center-Text "              ░░██████ ██████ ░░███░░░░░█░░██████ ░░███ ░░███  ░░███                "
    Center-Text "               ░███░█████░███  ░███  █ ░  ░███░███ ░███  ░███   ░███                "
    Center-Text "               ░███░░███ ░███  ░██████    ░███░░███░███  ░███   ░███                "
    Center-Text "               ░███ ░░░  ░███  ░███░░█    ░███ ░░██████  ░███   ░███                "
    Center-Text "               ░███      ░███  ░███ ░   █ ░███  ░░█████  ░███   ░███                "
    Center-Text "               █████     █████ ██████████ █████  ░░█████ ░░████████                 "
    Center-Text "              ░░░░░     ░░░░░ ░░░░░░░░░░ ░░░░░    ░░░░░   ░░░░░░░░                  "
    Write-Host ""
    Center-Text "(c) Set0z - https://github.com/Set0z"
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Версия $($ver)"} else {"Version $($ver)"})"
    Write-Host "`n"
    Set-ConsoleColor $Background_After_Color $Text_After_Color
}

#Отображения текста по центру
function Center-Text {
    param (
        [string]$Text,
        [switch]$NewLine
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
    if ($NewLine){Write-Host ""}
}


function Align-TextCenter {
    param (
        [string]$content,
        [int]$Offset = 42,
        [switch]$NoNewLine
    )
    $content = $content -replace '\x1b\[[0-9;]*(?<![0-9])m', ''  # Убираем атрибуты кроме цветов
    $content = $content + "$([char]27)[48;5;0m "

    # Получаем ширину консоли
    $consoleWidth = [Console]::WindowWidth

    # Вычисляем необходимое количество пробелов для центрирования
    $spacesNeeded = [Math]::Max(0, (($consoleWidth) / 2) - $Offset)

    # Создаём строку из пробелов
    $leadingSpaces = " " * [Math]::Floor($spacesNeeded)
    
    # Выводим отцентрированный текст
    Write-Output "$leadingSpaces$content"
    if ($NoNewLine) {} else {Write-Host ""}
}

#Загрузка файла
function Download-FileWithProgress {
    param (
        [string]$url,          # URL файла для скачивания
        [string]$outputFile,   # Путь для сохранения файла
        [string]$seconds = 2
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
            if (($currentTime - $lastProgressUpdateTime).TotalSeconds -gt $seconds) {
                # Преобразуем загруженные байты в мегабайты
                $totalBytesReadMB = [math]::Round($totalBytesRead / 1MB, 1)
                
                $percentComplete = ($totalBytesRead / $totalSize) * 100
                Write-Progress -PercentComplete $percentComplete -Status "Загрузка файла..." -Activity "Загружено: $totalBytesReadMB MB из $totalSizeMB MB     (Обновляется каждые $seconds секунд)"
                
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
            if (($currentTime - $lastProgressUpdateTime).TotalSeconds -gt $seconds) {
                # Преобразуем загруженные байты в мегабайты
                $totalBytesReadMB = [math]::Round($totalBytesRead / 1MB, 1)
                
                $percentComplete = ($totalBytesRead / $totalSize) * 100
                Write-Progress -PercentComplete $percentComplete -Status "File download..." -Activity "Downloaded: $totalBytesReadMB MB из $totalSizeMB MB     (Update every $seconds seconds)"
                
                $lastProgressUpdateTime = $currentTime
            }
            }
        }
        # Закрываем поток и выводим сообщение
        $fileStream.Close()
        Write-Progress -Activity "Download Complete" -Status " " -Completed
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Файл успешно скачан!"} else {"File is successfully downloaded!"})"
        Write-Host ""
        } else {
        Draw-Banner
        Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Ошибка при скачивании файла. Код ошибки: $($response.StatusCode)"} else {"Error while downloading file. Error code: $($response.StatusCode)"})"
        Write-Host ""
        Write-Progress -Activity " " -Status " " -Completed
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
                    #Write-Host "НЕТ ОШИБКИ"
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
        if($active_string.IndexOf("ProductCode:") -ne -1) {$tag_pos = $active_string.IndexOf("ProductCode:")} else {}
        #$tag_pos
        if ($tag_pos -ne $null) {
            $active_string = $active_string.Substring(0,$tag_pos)
        }
        #Write-Host "$active_string|`n"
        for ($j = $($active_string.Length -1); $j -ge 0; $j--) {
            if (($active_string[$j] -eq "1") -or ($active_string[$j] -eq "2") -or ($active_string[$j] -eq "3") -or ($active_string[$j] -eq "4") -or ($active_string[$j] -eq "5") -or ($active_string[$j] -eq "6") -or ($active_string[$j] -eq "8") -or ($active_string[$j] -eq "9") -or ($active_string[$j] -eq "0") -or ($active_string[$j] -eq ".")){
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

#перевод
function Lang-translate{
    param (
        [string]$rus,
        [string]$eng
    )
    if ($Menu_Lang -eq "ru-Ru"){return $rus} else {return $eng}
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
            } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
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

