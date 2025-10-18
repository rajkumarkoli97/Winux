$services = @(
    "Spooler","SSDPSRV","SstpSvc","DoSvc","SysMain","Fax","DiagTrack","DPS","WdiSystemHost",
    "TextInputManagementService","CameraEventService","Themes","UnistoreSvc_993e2",
    "UserDataSvc_993e2","PimIndexMaintenanceSvc_993e2","WpnService","PhoneSvc","WpnUserService_993e2",
    "CDPSvc","CDPUserSvc_993e2","DevicesFlowUserSvc_993e2","UdkUserSvc_993e2",
    "StateRepository","InstallService","AppXSvc",
    "cbdhsvc_69f04","CDPUserSvc_69f04","DsSvc","DusmSvc","ElevocService","HvHost",
    "IntelAudioService","igccservice","ipfsvc","WMIRegistrationService","jhi_service",
    "LADMLauncherService","logi_lamparray_service","NPSMSvc_69f04","StateRepository",
    "UdkUserSvc_69f04","TokenBroker",
    "CDPUserSvc_67462", "PimIndexMaintenanceSvc_67462", "TimeBrokerSvc"
)

foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        try {
            Stop-Service $svc -Force -ErrorAction SilentlyContinue
            Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "Stopped and disabled $svc"
        } catch {
            Write-Host "Could not disable $svc via PowerShell. Try Registry method."
        }
    }
}

