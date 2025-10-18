@echo off
setlocal

echo ============================================
echo Disabling all Windows Update & driver auto-installation...
echo ============================================

REM 1. Take ownership and grant permissions of update tasks folders

for %%F in (
    "C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator"
    "C:\Windows\System32\Tasks\Microsoft\Windows\WindowsUpdate"
    "C:\Windows\System32\Tasks\Microsoft\Windows\Servicing"
    "C:\Windows\System32\Tasks\Microsoft\Windows\Maintenance"
    "C:\Windows\System32\Tasks\Microsoft\Windows\WaaSMedic"
) do (
    echo Taking ownership and granting Administrators full control on %%F
    takeown /f %%F /r /d y
    icacls %%F /grant Administrators:F /t
)

REM 2. Disable all tasks by renaming *.job and files inside UpdateOrchestrator and WindowsUpdate folders
for %%D in (
    "C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator"
    "C:\Windows\System32\Tasks\Microsoft\Windows\WindowsUpdate"
) do (
    pushd %%D
    for %%T in (*) do (
        if /I not "%%~xT"==".disabled" (
            ren "%%T" "%%T.disabled"
        )
    )
    popd
)

REM 3. Stop and disable Windows Update services
echo Stopping and disabling Windows Update services...
sc stop wuauserv
sc stop bits
sc stop dosvc
sc stop WaaSMedicSvc

sc config wuauserv start= disabled
sc config bits start= disabled
sc config dosvc start= disabled
sc config WaaSMedicSvc start= disabled

REM 4. Disable driver auto installation via registry
echo Disabling driver auto installation via registry...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v SearchOrderConfig /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f

REM 5. Disable device installation settings (bonus)
echo Disabling Device Installation Settings (driver metadata downloads)...
powershell -Command ^
"Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching' -Name SearchOrderConfig -Value 0; ^
$policy = Get-WmiObject -Namespace root\cimv2\mdm\dmmap -Class MDM_Policy_Config01_RejectDeviceMetadataFromNetwork -ErrorAction SilentlyContinue; ^
if ($policy) { $policy.PreventDeviceMetadataFromNetwork = 1; $policy.Put() } else { Write-Host 'MDM policy class not found, skipping WMI step.' }"

REM 6. Block Windows Update from running via Hosts file (extra fallback)
echo 127.0.0.1    windowsupdate.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1    update.microsoft.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1    download.windowsupdate.com >> %SystemRoot%\System32\drivers\etc\hosts
echo 127.0.0.1    wustat.windows.com >> %SystemRoot%\System32\drivers\etc\hosts

echo ============================================
echo All done. Windows Update and driver auto-installation should now be disabled.
echo Reboot your PC to apply changes.
echo ============================================

pause
endlocal
