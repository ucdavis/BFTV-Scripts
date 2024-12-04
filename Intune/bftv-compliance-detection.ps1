
# Check for BIOS Password
$BIOS_PW = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject | Where-Object NameId -EQ "Admin" | Select-Object -ExpandProperty IsPasswordSet

# Check if BigFix is Installed
$InstalledSoftware = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
if ($InstalledSoftware -like "*BigFix Client*") {
	$DetectBigFix = "Detected"
}
else {
	$DetectBigFix = "Not Detected"
}

# Output variables
$output = @{ BIOS_PW = $BIOS_PW; DetectBigFix = $DetectBigFix}
return $output | ConvertTo-Json -Compress