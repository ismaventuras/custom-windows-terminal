$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

$profiles = @{
    "Windows Waves" = "https://raw.githubusercontent.com/ismaventuras/custom-windows-terminal/master/themes/windows-waves.json"
    "Windows Waves Revolution" = "https://raw.githubusercontent.com/ismaventuras/custom-windows-terminal/master/themes/windows-waves-revolution.json"
    "LoFi Girl" = "https://raw.githubusercontent.com/ismaventuras/custom-windows-terminal/master/themes/lofi-girl.json"
    "Vegeta" = "https://raw.githubusercontent.com/ismaventuras/custom-windows-terminal/master/themes/vegeta.json"
}

function Show-ProfileMenu {
    Write-Host "Available profiles:" 
    $i = 1
    foreach ($p in $profiles.Keys) {
        Write-Host "$i. $p"
        $i++
    }
    $selection = Read-Host "Enter the number of the profile you want to install"
    $profileNames = $profiles.Keys
    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $profileNames.Count) {
        $i = 1
        foreach ($key in $profiles.Keys) {
            if($i -eq $selection){
                Remove-Profile -ProfileName $key
                break
            }
            $i++
        }
    } else {
        Write-Host "Invalid selection. Please run the script again and select a valid profile number."
    }
}


function Remove-Profile {
    param (
        [string]$ProfileName
    )
    $settingsJson = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
    $existingProfile = $settingsJson.profiles.list | Where-Object { $_.name -eq $ProfileName }

    if ($existingProfile) {
        if ($settingsJson.defaultProfile -eq $existingProfile.guid) {
            # Find another profile to set as default
            $newDefaultProfile = $settingsJson.profiles.list | Where-Object { $_.guid -ne $existingProfile.guid } | Select-Object -First 1
            if ($newDefaultProfile) {
                $settingsJson.defaultProfile = $newDefaultProfile.guid
                Write-Host "Profile '$profileName' was the default profile. Default profile changed to '$($newDefaultProfile.name)'."
            } else {
                Write-Host "Profile '$profileName' is the only profile. Cannot delete it without another default profile."
                return
            }
        }
        $settingsJson.profiles.list = $settingsJson.profiles.list | Where-Object { $_.name -ne $ProfileName }
        # Convert the updated settings back to JSON
        $updatedSettingsJson = $settingsJson | ConvertTo-Json -Depth 10
        # Write the updated JSON back to the settings file
        Set-Content -Path $settingsPath -Value $updatedSettingsJson
        Write-Host "Profile '$ProfileName' deleted successfully."
    } else {
        Write-Host "Profile '$ProfileName' does not exist."
    }
}

if ($ProfileName) {
    Remove-Profile $ProfileName
}  else {
    Show-ProfileMenu
}