#region Объявление переменных
$(if($Menu_Lang -eq "ru-Ru"){$host.ui.RawUI.WindowTitle = "Конфигурация удаленного рабочего стола 🖧"} else {$host.ui.RawUI.WindowTitle = "Remoute Desktop Configuration 🖧"})
$scriptDir = $PSScriptRoot
$Menu_Lang = $env:BURAN_lang
if ($PSScriptRoot -eq "") {Import-Module $(Join-Path -Path $env:TEMP -ChildPath 'Buran_Modules.psm1') -DisableNameChecking} else {$scriptDir = $PSScriptRoot ; Import-Module $($PSScriptRoot + "/modules") -DisableNameChecking}
if (-not ((Get-Item "HKLM:\System\CurrentControlSet\Control\Terminal Server").Property -contains "updateRDStatus")) {Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "updateRDStatus" -Value 1}
$sel = "$([char]27)[48;5;2;38;5;0m"   # зелёный фон, черный текст, выделенный
$grn = "$([char]27)[48;5;0;38;5;2m"   # черный фон, зеленый текст
$exared = "$([char]27)[4;48;5;0;38;5;1m"   # черный фон, красный текст, подчеркнутый
$exa = "$([char]27)[4;48;5;0;38;5;2m"   # черный фон, зеленый текст, подчеркнутый
$grn = "$([char]27)[24;48;5;0;38;5;2m"   # черный фон, зеленый текст, без подчёркивания
$i = 0
$DetailSh = $false
#endregion

function Check-FirewallStatus($name) {
    $firewallState = Get-NetFirewallProfile | Where-Object { ($_.Name -eq $name) }
    if ($firewallState.Enabled -eq $true) {return "Enabled"} else {return "Disabled"}
}

function Get-FirewallStatus {
    $firewallStatus = (Get-NetFirewallProfile | Where-Object {($_.Enabled -eq $true) -and ($_.Name -ne 'Domain')})
    if ($firewallStatus) {return "Enabled"} else {return "Disabled"}
}

function MainMenu{
    $DenyTSC = $(Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections
    $URDStatus = $(Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "updateRDStatus").updateRDStatus
    $BlankPass = $(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse").LimitBlankPasswordUse
    if ($(Get-FirewallStatus) -eq "Disabled") {$Firewall = $true} else {$Firewall = $false}

    Draw-Banner
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Статус Брандмауэра:"} else {"Firewall status:"}) | $(if($Menu_Lang -eq "ru-Ru"){"Домен: "} else {"Domain: "})$(if($(Check-FirewallStatus 'Domain') -eq "Disabled"){"${exared}Disabled$grn"} else {"${exa}Enabled$grn"}) | $(if($Menu_Lang -eq "ru-Ru"){"Частный: "} else {"Private: "})$(if($(Check-FirewallStatus 'Private') -eq "Disabled"){"${exared}Disabled$grn"} else {"${exa}Enabled$grn"}) | $(if($Menu_Lang -eq "ru-Ru"){"Общедоступный: "} else {"Public: "})$(if($(Check-FirewallStatus 'Public') -eq "Disabled"){"${exared}Disabled$grn"} else {"${exa}Enabled$grn"}) |" -NewLine
    Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выберите действие"} else {"Choose the Action"})" -NewLine

    Align-TextCenter "[1] $(if($Menu_Lang -eq "ru-Ru"){"Белый список IP-адресов\"} else {"IP whitelist\"})"
    Align-TextCenter "$(if(($DenyTSC -eq 1) -and ($URDStatus -eq 1)){"[2] ${exa}Enable$grn |"}else{"${sel}[2]${grn} ${exa}Disable${grn} |"}) $(if($Menu_Lang -eq "ru-Ru"){"Удаленный рабочий стол"} else {"Remote desktop"})"
    Align-TextCenter "$(if($BlankPass -eq 1){"[3] ${exa}Enable$grn  |"}else{"${sel}[3]${grn} ${exa}Disable${grn} |"}) $(if($Menu_Lang -eq "ru-Ru"){"Разрешить пустой пароль              (Если у пользователя нет пароля)"} else {"Allow Blank Password       (If user don't have password)"})"
    Align-TextCenter "$(if($Firewall -eq 1){"[4] ${exa}Enable$grn  |"}else{"${sel}[4]${grn} ${exa}Disable${grn} |"}) $(if($Menu_Lang -eq "ru-Ru"){"Брандмауэр Windows                   (Необходим для белого списка IP)"} else {"Windows Firewall              (Need for Ip whitelist)"})"
    Align-TextCenter "$(if($DetailSh){"$sel[5]$grn"}else{"[5]"}) $(if($Menu_Lang -eq "ru-Ru"){"Показать данные для подключения:          $(if($DetailSh){"Пользователь: $Env:UserName | IP: $ipAddress"} else {"Пользователь: ***** | IP: ***.***.***.***"})"} else {"Show connection details:         $(if($DetailSh){"Username: $Env:UserName | IP: $ipAddress"} else {"Username: ***** | IP: ***.***.***.***"})"})"
    Align-TextCenter "$sel[6]$grn $(if($Menu_Lang -eq "ru-Ru"){"${sel}Выход в меню$grn"} else {"${sel}Back to menu$grn"})" -NewLine

    do {
        $choice = [Console]::ReadKey($true).Key
        if (($choice -eq "D1") -or ($choice -eq "NumPad1")){
            Draw-Banner
            $ipAddresses = @()
            
            Write-Host ""
            Write-Host "$(if($Menu_Lang -eq "ru-Ru"){"Введите IP-адрес или введите пустой для завершения (Формат: ***.***.***.***)"} else {"Enter IP address or enter blank to complete (Format: ***.***.***.***)"})"
            do {
                $i = $i + 1
                $ip = Read-Host "$i IP address: "

                if ($ip -ne "") {
                    if ($ip -match '^([0-9]{1,3}\.){3}[0-9]{1,3}$') {
                        $valid = $true
                        foreach ($octet in $ip.Split('.')) {
                            if ([int]$octet -gt 255 -or [int]$octet -lt 0) {
                                $valid = $false
                                break
                            }
                        }
                        if ($valid) {$ipAddresses += $ip} else {Write-Host "$(if($Menu_Lang -eq "ru-Ru"){"`n[!] Невозможный IP:"} else {"`n[!] Impossible IP:"}) $ip `n"}
                    } else {
                        Write-Host "$(if($Menu_Lang -eq "ru-Ru"){"`n[!] Невозможный IP:"} else {"`n[!] Impossible IP:"}) $ip `n"
                        $i = $i - 1
                    }
                }
            } while ($ip -ne "")
            if ($ipAddresses.Count -ne 0){
                $ipString = $ipAddresses -join '|RA4='
                $command = "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules' -Name 'RemoteDesktop-UserMode-In-TCP' -Value 'v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=3389|RA4=$ipString|App=%SystemRoot%\system32\svchost.exe|Svc=termservice|Name=@FirewallAPI.dll,-28775|Desc=@FirewallAPI.dll,-28756|EmbedCtxt=@FirewallAPI.dll,-28752|'"
                Invoke-Expression $command
            } else {
                $command = "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules' -Name 'RemoteDesktop-UserMode-In-TCP' -Value 'v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=3389|App=%SystemRoot%\system32\svchost.exe|Svc=termservice|Name=@FirewallAPI.dll,-28775|Desc=@FirewallAPI.dll,-28756|EmbedCtxt=@FirewallAPI.dll,-28752|'"
                Invoke-Expression $command
            }
            $i = 0
            MainMenu
        }
        if (($choice -eq "D2") -or ($choice -eq "NumPad2")){
            Draw-Banner
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Выполняется…"} else {"In progress…"})"
            if(($DenyTSC -eq 1) -and ($URDStatus -eq 1)){
                Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"
                Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
            } else {
                Disable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"
                Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
            }
            Clear-Host
            Write-Host "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"Готово!"} else {"Done!"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"______________________"} else {"__________________"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"|Нажмите любую кнопку|"} else {"|Press any button|"})"
            Center-Text "$(if($Menu_Lang -eq "ru-Ru"){"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"} else {"‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"})"
            Write-Host ""
            do {
                $notice = [Console]::ReadKey($true).Key
            } until ($notice)
            MainMenu
        }
        if (($choice -eq "D3") -or ($choice -eq "NumPad3")){
            if($BlankPass -eq 1){
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 0 -Type DWord
            } else {
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LimitBlankPasswordUse" -Value 1 -Type DWord
            }
            MainMenu
        }
        if (($choice -eq "D4") -or ($choice -eq "NumPad4")){
            if($Firewall){
                Set-NetFirewallProfile -All -Enabled True
            } else {
                Set-NetFirewallProfile -All -Enabled False
            }
            MainMenu
        }
        if (($choice -eq "D5") -or ($choice -eq "NumPad5")){
            if (-not $ipAddress) {
                try {$ipAddress = (Get-NetIPAddress -InterfaceAlias Ethernet* -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress ; if (-not $ipAddress) {throw}} catch {if($Menu_Lang -eq "ru-Ru"){$ipAddress = "не определён"} else {$ipAddress = "not defined"}}
            }
            $DetailSh = -not $DetailSh ; MainMenu
        }
        if (($choice -eq "D6") -or ($choice -eq "NumPad6") -or ($choice -eq "Escape")){Goto-main}
    } until ($choice -eq "Escape")
}

MainMenu
