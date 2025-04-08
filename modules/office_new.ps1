#Глобальные переменные
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Скачивание и Активация Офис"} else {$host.ui.RawUI.WindowTitle = "Office Download and Activation"})
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
$ver= $env:version
$downloadsPath = Join-Path $HOME "Downloads"
$selected_programs = New-Object System.Collections.ArrayList

if ($PSScriptRoot -eq "") {
    Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking
} else {
    $scriptDir = $PSScriptRoot
    Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking
}

$Debug = $false

#Import-Module "C:\Users\admin\Desktop\BURAN_Menu\modules\modules.psm1" -DisableNameChecking



#######################################



function Project_Visio_ver{
    param (
        [string]$Name,
        [string]$Exit_to
    )
    Draw-Banner
    Center-Text "   $(Lang-translate -rus "Выберите версию:" -eng "Choose Version:")" -NewLine
    Align-TextCenter "[1] $Name Professional"
    Align-TextCenter "[2] $Name Standard"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[3] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            $global:result_ver = "Professional"
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            $global:result_ver = "Standart"
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){& $Exit_to}
        if ($choice -eq "Escape"){& $Exit_to}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}

function installation_select{
    param(
        [string]$Office_version,
        [string]$Download_directory
    )
    if ($Office_version -eq ""){}
    if (($Office_version -eq "Project") -or ($Office_version -eq "Visio")){
        Draw-Banner
        Center-Text "$(Lang-translate -rus "Установка..." -eng "Installing...")"

        $used = (Get-PSDrive -PSProvider FileSystem).Name
        $all = [char[]]([char]'C'..[char]'Z')  
        $drive_letter = $null
        foreach ($letter in $all) {
            if ($letter -notin $used) {
            $drive_letter = $letter
            $drive_letter = $drive_letter + ":"
             break
            }
        }
        $diskImg = Mount-DiskImage -ImagePath $Download_directory -NoDriveLetter
        $volInfo = $diskImg | Get-Volume
        mountvol $drive_letter $volInfo.UniqueId
        if ([System.IntPtr]::Size -eq 8) {$edition = "64"} else {$edition = "32"}
        $setup_path = "$drive_letter\Office\Setup"
        $setup_path = $setup_path + $edition + ".exe"
        Start-Process -FilePath $setup_path -Wait -NoNewWindow
        First_menu
    }
    do {
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Выберите что нужно установить" -eng "Select what you need to install")" -NewLine
            Write-Host ""
            Align-TextCenter "$(if($selected_programs.Contains("Word")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[1]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[1]"}) Word       $(if($selected_programs.Contains("Excel")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[2]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[2]"}) Excel       $(if($selected_programs.Contains("PowerPoint")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[3]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[3]"}) PowerPoint" -Offset 22
            Align-TextCenter "$(if($selected_programs.Contains("OneNote")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[4]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[4]"}) OneNote    $(if($selected_programs.Contains("Outlook")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[5]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[5]"}) Outlook     $(if($selected_programs.Contains("Publisher")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[6]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[6]"}) Publisher" -Offset 22
            if ($Office_version -ne "O365ProPlusRetail"){Align-TextCenter "$(if($selected_programs.Contains("Access")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Access" -NoNewLine -Offset 7}
            if ($Office_version -eq "O365ProPlusRetail"){
                Align-TextCenter "$(if($selected_programs.Contains("Access")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[7]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[7]"}) Access     $(if($selected_programs.Contains("Skype")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[8]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[8]"}) Skype       $(if($selected_programs.Contains("Teams")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[9]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[9]"}) Teams" -Offset 22
                Align-TextCenter "$(if($selected_programs.Contains("OneDrive")){"$([char]27)[48;5;2m$([char]27)[38;5;0m[0]$([char]27)[48;5;0m$([char]27)[38;5;2m"} else {"[0]"}) OneDrive" -Offset 7
            } else {Write-Host " "}
            Write-Host "`n"
            Center-Text "$(Lang-translate -rus "[Enter] Подтвердить выбор    [Esc] Выход в Главное Меню" -eng "[Enter] Confirm the Choice    [Esc] Exit to Main Menu")"


            $choice = [Console]::ReadKey($true).Key
            if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                if($selected_programs.Contains("Word")){$selected_programs.Remove("Word")} else {$selected_programs.Add("Word") | Out-Null}
            }
            if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                if($selected_programs.Contains("Excel")){$selected_programs.Remove("Excel")} else {$selected_programs.Add("Excel") | Out-Null} 
            }
            if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
                if($selected_programs.Contains("PowerPoint")){$selected_programs.Remove("PowerPoint")} else {$selected_programs.Add("PowerPoint") | Out-Null}
            }
            if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
                if($selected_programs.Contains("OneNote")){$selected_programs.Remove("OneNote")} else {$selected_programs.Add("OneNote") | Out-Null} 
            }
            if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
                if($selected_programs.Contains("Outlook")){$selected_programs.Remove("Outlook")} else {$selected_programs.Add("Outlook") | Out-Null}
            }
            if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
                if($selected_programs.Contains("Publisher")){$selected_programs.Remove("Publisher")} else {$selected_programs.Add("Publisher") | Out-Null}
            }
            if (($choice -eq "D7") -or ($choice -eq "NumPad7")){
                if($selected_programs.Contains("Access")){$selected_programs.Remove("Access")} else {$selected_programs.Add("Access") | Out-Null}
            }
            if (($choice -eq "D8") -or ($choice -eq "NumPad8")){
                if($selected_programs.Contains("Skype")){$selected_programs.Remove("Skype")} else {$selected_programs.Add("Skype") | Out-Null}
            }
            if (($choice -eq "D9") -or ($choice -eq "NumPad9")){
                if($selected_programs.Contains("Teams")){$selected_programs.Remove("Teams")} else {$selected_programs.Add("Teams") | Out-Null}
            }
            if (($choice -eq "D0") -or ($choice -eq "NumPad0")){
                if($selected_programs.Contains("OneDrive")){$selected_programs.Remove("OneDrive")} else {$selected_programs.Add("OneDrive") | Out-Null}
            }
            if ($choice -eq "Escape"){
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Вы уверенны что хотите выйти?" -eng "Are you sure you want to exit?")" -NewLine
                Center-Text "$(Lang-translate -rus "[1] Да    [2] Нет" -eng "[1] Yes    [2] No")"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                        First_menu
                    }
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        installation_select -Office_version $Office_version -Download_directory $Download_directory
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
            }
            if ($choice -eq "Enter"){
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Установка..." -eng "Installing...")"

                $used = (Get-PSDrive -PSProvider FileSystem).Name
                $all = [char[]]([char]'C'..[char]'Z')  
                $drive_letter = $null
                foreach ($letter in $all) {
                    if ($letter -notin $used) {
                        $drive_letter = $letter
                        $drive_letter = $drive_letter + ":"
                        break
                    }
                }
                $diskImg = Mount-DiskImage -ImagePath $Download_directory -NoDriveLetter
                $volInfo = $diskImg | Get-Volume
                mountvol $drive_letter $volInfo.UniqueId
                if ([System.IntPtr]::Size -eq 8) {$edition = "64"} else {$edition = "32"}
                $ODT = "$env:temp\ODT"
                $ODT_Path = Join-Path $env:temp "ODT.exe"
                Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18324-20194.exe" -OutFile $ODT_Path -UseBasicP
                Start-Process -Wait -NoNewWindow -FilePath $ODT_Path -ArgumentList "/extract:$ODT /quiet"
                $config_file = "$env:temp\config.xml"
                "<Configuration>" | Add-Content -Path $config_file
                "  <Add OfficeClientEdition=`"$($edition)`" SourcePath=`"$($drive_letter)\`">" | Add-Content -Path $config_file
                "    <Product ID=`"$($Office_version)`">" | Add-Content -Path $config_file
                "      <Language ID=`"$($language)`" />" | Add-Content -Path $config_file
                if($selected_programs.Contains("Word") -eq $false){"      <ExcludeApp ID=`"Word`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("Excel") -eq $false){"      <ExcludeApp ID=`"Excel`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("PowerPoint") -eq $false){"      <ExcludeApp ID=`"PowerPoint`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("OneNote") -eq $false){"      <ExcludeApp ID=`"OneNote`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("Outlook") -eq $false){"      <ExcludeApp ID=`"Outlook`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("Publisher") -eq $false){"      <ExcludeApp ID=`"Publisher`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("Access") -eq $false){"      <ExcludeApp ID=`"Access`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("Skype") -eq $false){"      <ExcludeApp ID=`"Skype`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("Teams") -eq $false){"      <ExcludeApp ID=`"Teams`" />" | Add-Content -Path $config_file}
                if($selected_programs.Contains("OneDrive") -eq $false){"      <ExcludeApp ID=`"OneDrive`" />" | Add-Content -Path $config_file}
                "      <ExcludeApp ID=`"Lync`" />" | Add-Content -Path $config_file
                "      <ExcludeApp ID=`"Groove`" />" | Add-Content -Path $config_file
                "    </Product>" | Add-Content -Path $config_file
                "  </Add>" | Add-Content -Path $config_file
                "  <Display Level=`"Full`" AcceptEULA=`"TRUE`"/>" | Add-Content -Path $config_file
                "</Configuration>" | Add-Content -Path $config_file
                $ODT_Path_exe = $ODT_Path
                $ODT_Path = Join-Path $ODT "\setup.exe"
                Start-Process -Wait -NoNewWindow -FilePath $ODT_Path -ArgumentList "/configure $config_file"

                Dismount-DiskImage -ImagePath $Download_directory
                Remove-Item -Path $ODT -Recurse -Force
                Remove-Item -Path $ODT_Path_exe -Recurse -Force
                Remove-Item -Path $Download_directory -Recurse -Force
                Remove-Item -Path $config_file -Recurse -Force
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Установлено!" -eng "Installed!")"
                
                pause

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Акстивировать Office?" -eng "Activate Office?")" -NewLine
                Center-Text "$(Lang-translate -rus "[1] Да    [2] Нет" -eng "[1] Yes    [2] No")"
                do {
                    $choice = [Console]::ReadKey($true).Key
                    if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
                        Activation -OfficeVersion $Office_version
                    }
                    if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
                        First_menu
                    }
                } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")))
            }
        } until (($choice -eq "Enter") -or ($choice -eq "Escape")) #Выход из цикла

}

function Activation{
    param(
        [string]$OfficeVersion
    )
    if($OfficeVersion -eq "ProPlus2024Retail"){$OfficeVersion = "ProPlus2021VL_KMS*.xrm-ms"} elseif ($OfficeVersion -eq "O365ProPlusRetail"){$OfficeVersion = "ProPlus2024VL_KMS*.xrm-ms"} elseif ($OfficeVersion -eq "ProPlus2021Retail"){$OfficeVersion = "ProPlus2021VL_KMS*.xrm-ms"} elseif ($OfficeVersion -eq "ProPlus2019Retail"){$OfficeVersion = "ProPlus2019VL_KMS*.xrm-ms"} elseif ($OfficeVersion -eq "ProPlusRetail"){$OfficeVersion = "ProPlusVL_KMS*.xrm-ms"}
    if($OfficeVersion -eq "") {
        Draw-Banner
        Center-Text "$(Lang-translate -rus "Выберите версию Office:" -eng "Select the Office version:")" -NewLine
        Align-TextCenter "[1] Office 365"
        Align-TextCenter "[2] Office 2024"
        Align-TextCenter "[3] Office 2021"
        Align-TextCenter "[4] Office 2019"
        Align-TextCenter "[5] Office 2016"
        Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[6] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"
        do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
           $OfficeVersion = "ProPlus2021VL_KMS*.xrm-ms"
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
           $OfficeVersion = "ProPlus2021VL_KMS*.xrm-ms"
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
           $OfficeVersion = "ProPlus2021VL_KMS*.xrm-ms"
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
           $OfficeVersion = "ProPlus2019VL_KMS*.xrm-ms"
        }
        if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
           $OfficeVersion = "ProPlusVL_KMS*.xrm-ms"
        }
        if (($choice -eq "D6") -or ($choice -eq "NumPad6")){
           First_menu
        }
        if ($choice -eq "Escape"){First_menu}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or (($choice -eq "D5") -or ($choice -eq "NumPad5")) -or (($choice -eq "D6") -or ($choice -eq "NumPad6")) -or ($choice -eq "Escape")) #Выход из цикла
    }
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Активация..." -eng "Activation...")" -NewLine

    if(Test-Path "${env:ProgramFiles(x86)}\Microsoft Office\Office16") {
        $office_vbs_path = "${env:ProgramFiles(x86)}\Microsoft Office\Office16\ospp.vbs"
        $inslic_path = "${env:ProgramFiles(x86)}\Microsoft Office\root\Licenses16"
    } elseif (Test-Path "${env:ProgramFiles}\Microsoft Office\Office16"){
        $office_vbs_path = "${env:ProgramFiles}\Microsoft Office\Office16\ospp.vbs"
        $inslic_path = "${env:ProgramFiles}\Microsoft Office\root\Licenses16"
    } else {
        Center-Text "$(Lang-translate -rus "Не удаётся найти установленный Office!" -eng "Cannot find an installed Office!")"
        First_menu
        pause
    }
    Get-ChildItem "$inslic_path\$OfficeVersion" | ForEach-Object {cscript $office_vbs_path /inslic:"$inslic_path\$($_.Name)"}
    cscript $office_vbs_path /setprt:1688 ; Start-Sleep -Seconds 3
    cscript $office_vbs_path /unpkey:6F7TH ; Start-Sleep -Seconds 3
    if ($OfficeVersion -eq "ProPlus2021VL_KMS*.xrm-ms"){cscript $office_vbs_path /inpkey:FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH ; Start-Sleep -Seconds 3} elseif ($OfficeVersion -eq "ProPlus2019VL_KMS*.xrm-ms"){cscript $office_vbs_path /inpkey:NMMKJ-6RK4F-KMJVX-8D9MJ-6MWKP ; Start-Sleep -Seconds 3} elseif ($OfficeVersion -eq "ProPlusVL_KMS*.xrm-ms"){cscript $office_vbs_path /inpkey:XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99 ; Start-Sleep -Seconds 3}
    cscript $office_vbs_path /sethst:e8.us.to ; Start-Sleep -Seconds 3
    cscript $office_vbs_path /act ; Start-Sleep -Seconds 3
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Активировано!" -eng "Activated!")" -NewLine
    pause
    First_menu
}

function Office_Already_Fownloaded{
    param (
        [string]$Version
    )
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Есть ли у вас образ диска $($Version).img?" -eng "Do you have a disk image $($Version).img?")" -NewLine
    Center-Text "$(Lang-translate -rus "[1] Нет   [2] Да" -eng "[1] No   [2] Yes")" -NewLine

    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            $download_dir = Folder-choose -default $false
            if ($download_dir -eq $null) {version}
            $download_dir = $download_dir + "\$($Version).img"
            installation_select -Office_version $Version -Download_directory $download_dir
        }
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))) #Выход из цикла
}



#######################################



function First_menu {
    Draw-Banner
    Center-Text "   $(Lang-translate -rus "Выберите действие:" -eng "Choose the action:")" -NewLine
    Align-TextCenter "[1] $(Lang-translate -rus "Загрузка" -eng "Download")"
    Align-TextCenter "[2] $(Lang-translate -rus "Активация" -eng "Activation")"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[3] $(Lang-translate -rus "Выход" -eng "Exit")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
           Language
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
           Activation
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){Goto-main}
        if ($choice -eq "Escape"){Goto-main}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}

function Language{
    Draw-Banner
    Center-Text "   $(Lang-translate -rus "Выберите язык:" -eng "Choose the Language:")" -NewLine
    Align-TextCenter "[1] $(Lang-translate -rus "Русский" -eng "Russian")"
    Align-TextCenter "[2] $(Lang-translate -rus "Английский" -eng "English")"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[3] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            $language = "ru-RU"
            $lang_disp = "Ru"
            version
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            $language = "en-US"
            $lang_disp = "En"
            version
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){First_menu}
        if ($choice -eq "Escape"){First_menu}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}

function version {
    Draw-Banner
    Center-Text "   $(Lang-translate -rus "Выберите версию:" -eng "Choose the Version:")" -NewLine
    Align-TextCenter "[1] Office 365"
    Align-TextCenter "[2] Office 2024"
    Align-TextCenter "[3] Office 2021"
    Align-TextCenter "[4] Office 2019"
    Align-TextCenter "[5] Office 2016"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[6] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            office_365
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            office_2024
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            office_2021
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
            office_2019
        }
        if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
            office_2016
        }
        if (($choice -eq "D6") -or ($choice -eq "NumPad6")){Language}
        if ($choice -eq "Escape"){Language}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2"))-or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or ($choice -eq "Escape")) #Выход из цикла
}



#######################################



function office_365{
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Выберите нужный пакет:" -eng "Select the desired package:")"
    Center-Text "File size: ($([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(File-size 'https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/ru-RU/O365ProPlusRetail.img')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb .iso)" -NewLine
    Align-TextCenter "[1] Office 365 Professional | (Word, Excel, PowerPoint OneNote, Access, OneDrive" -NoNewLine
    Align-TextCenter "                               Outlook (classic), Publisher, Skype , Teams)"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[2] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            Office_Already_Fownloaded -Version "O365ProPlusRetail"

            $download_dir = Folder-choose -default $false

            if ($download_dir -eq $null) {office_365}

            $download_dir = $download_dir + "\O365ProPlusRetail.img"
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
            Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/O365ProPlusRetail.img")" -seconds 5
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
            Write-Host " "
            pause
            installation_select -Office_version "O365ProPlusRetail" -Download_directory $download_dir

        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){version}
        if ($choice -eq "Escape"){version}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or ($choice -eq "Escape")) #Выход из цикла
}

function office_2024{
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Выберите нужный пакет:" -eng "Select the desired package:")"
    Center-Text "File size: ($([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(File-size 'https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/ru-RU/ProPlus2024Retail.img')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb .iso)" -NewLine
    Align-TextCenter "[1] Office 2024 Professional Plus | (Word, Excel, PowerPoint, OneNote, Outlook, Publisher, Access" -NoNewLine
    Align-TextCenter "                                     Skype, Teams)"
    Align-TextCenter "[2] Project 2024"
    Align-TextCenter "[3] Visio 2024"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[4] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"

    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            Office_Already_Fownloaded -Version "ProPlus2024Retail"

            $download_dir = Folder-choose -default $false

            if ($download_dir -eq $null) {office_2024}

            $download_dir = $download_dir + "\ProPlus2024Retail.img"

            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
            Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProPlus2024Retail.img")" -seconds 5
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
            Write-Host " "
            pause
            installation_select -Office_version "ProPlus2024Retail" -Download_directory $download_dir

        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            Project_Visio_ver -Name Project -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectStd2024Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectStd2024Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectPro2024Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectPro2024Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            Project_Visio_ver -Name Visio -Exit_to office_2024
            if ($global:result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioStd2024Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioStd2024Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            } else {
                Write-Host "else"
                pause
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioPro2024Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioPro2024Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){version}
        if ($choice -eq "Escape"){version}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}

function office_2021{
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Выберите нужный пакет:" -eng "Select the desired package:")"
    Center-Text "File size: ($([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(File-size 'https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/ru-RU/ProPlus2021Retail.img')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb .iso)" -NewLine
    Align-TextCenter "[1] Office 2021 Professional Plus | (Word, Excel, PowerPoint, OneNote, Outlook, Publisher, Access" -NoNewLine
    Align-TextCenter "                                     Skype, Teams)"
    Align-TextCenter "[2] Project 2021"
    Align-TextCenter "[3] Visio 2021"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[4] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        Office_Already_Fownloaded -Version "ProPlus2021Retail"
            $download_dir = Folder-choose -default $false

            if ($download_dir -eq $null) {office_2021}

            $download_dir = $download_dir + "\ProPlus2021Retail.img"

            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
            Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProPlus2021Retail.img")" -seconds 5
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
            Write-Host " "
            pause
            installation_select -Office_version "ProPlus2021Retail" -Download_directory $download_dir
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            Project_Visio_ver -Name Project -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectStd2021Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectStd2021Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectPro2021Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectPro2021Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            Project_Visio_ver -Name Visio -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioStd2021Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioStd2021Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioPro2021Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioPro2021Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){version}
        if ($choice -eq "Escape"){version}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}

function office_2019{
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Выберите нужный пакет:" -eng "Select the desired package:")"
    Center-Text "File size: ($([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(File-size 'https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/ru-RU/ProPlus2019Retail.img')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb .iso)" -NewLine
    Align-TextCenter "[1] Office 2019 Professional Plus | (Word, Excel, PowerPoint, OneNote, Outlook, Publisher, Access" -NoNewline
    Align-TextCenter "                                     Skype, Teams)"
    Align-TextCenter "[2] Project 2019"
    Align-TextCenter "[3] Visio 2019"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[4] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
        Office_Already_Fownloaded -Version "ProPlus2019Retail"
            $download_dir = Folder-choose -default $false

            if ($download_dir -eq $null) {office_2019}

            $download_dir = $download_dir + "\ProPlus2019Retail.img"

            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
            Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProPlus2019Retail.img")" -seconds 5
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
            Write-Host " "
            pause
            installation_select -Office_version "ProPlus2019Retail" -Download_directory $download_dir
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            Project_Visio_ver -Name Project -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectStd2019Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectStd2019Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectPro2019Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectPro2019Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            Project_Visio_ver -Name Visio -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioStd2019Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioStd2019Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioPro2019Retail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioPro2019Retail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){version}
        if ($choice -eq "Escape"){version}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}

function office_2016{
    Draw-Banner
    Center-Text "$(Lang-translate -rus "Выберите нужный пакет:" -eng "Select the desired package:")"
    Center-Text "File size: ($([char]27)[48;5;0m$([char]27)[38;5;10m$([char]27)[4m$(File-size 'https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/ru-RU/ProPlusRetail.img')$([char]27)[0m$([char]27)[48;5;0m$([char]27)[38;5;10m Mb .iso)" -NewLine
    Align-TextCenter "[1] Office 2016 Professional Plus | (Word, Excel, PowerPoint, OneNote, Outlook, Publisher, Access" -NoNewLine
    Align-TextCenter "                                     Skype, Teams)"
    Align-TextCenter "[2] Project 2016"
    Align-TextCenter "[3] Visio 2016"
    Align-TextCenter "$([char]27)[48;5;2m$([char]27)[38;5;0m[4] $(Lang-translate -rus "Назад" -eng "Back")$([char]27)[48;5;0m$([char]27)[38;5;2m"


    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            Office_Already_Fownloaded -Version "ProPlusRetail"
            $download_dir = Folder-choose -default $false

            if ($download_dir -eq $null) {office_2016}

            $download_dir = $download_dir + "\ProPlusRetail.img"

            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
            Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProPlusRetail.img")" -seconds 5
            Draw-Banner
            Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
            Write-Host " "
            pause
            installation_select -Office_version "ProPlusRetail" -Download_directory $download_dir
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            Project_Visio_ver -Name Project -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectStdRetail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectStdRetail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\ProjectProRetail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/ProjectProRetail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Project" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            Project_Visio_ver -Name Visio -Exit_to office_2024
            if ($result_ver -eq "Standart") {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioStdRetail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioStdRetail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            } else {
                $download_dir = Folder-choose -default $false

                if ($download_dir -eq $null) {office_2024}

                $download_dir = $download_dir + "\VisioProRetail.img"

                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загрузка..." -eng "Downloading...")"
                Download-FileWithProgress -outputFile $download_dir -url "$("https://officecdn.microsoft.com/db/492350f6-3a01-4f97-b9c0-c7c6ddf67d60/media/" + $language + "/VisioProRetail.img")" -seconds 5
                Draw-Banner
                Center-Text "$(Lang-translate -rus "Загружено!" -eng "Downloaded!")"
                Write-Host " "
                pause
                installation_select -Office_version "Visio" -Download_directory $download_dir
            }
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){version}
        if ($choice -eq "Escape"){version}
    } until ((($choice -eq "D1") -or ($choice -eq "NumPad1")) -or (($choice -eq "D2") -or ($choice -eq "NumPad2")) -or (($choice -eq "D3") -or ($choice -eq "NumPad3")) -or (($choice -eq "D4") -or ($choice -eq "NumPad4")) -or ($choice -eq "Escape")) #Выход из цикла
}



#######################################



#начало

First_menu

pause
