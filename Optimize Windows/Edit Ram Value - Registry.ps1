$regPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -Value $regPath
Start-Process regedit.exe
