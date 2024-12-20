# Check for BIOS Password
$BIOS_test = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject | Where-Object NameId -EQ "Admin" | Select-Object -ExpandProperty IsPasswordSet
$BIOS_PW = $false	
if ($BIOS_test)
{
	$BIOS_PW = $true
}

# Check if BigFix is Installed
$InstalledSoftware = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
if ($InstalledSoftware.DisplayName -like "BigFix Client") {
	$DetectBigFix = "Detected"
}
else {
	$DetectBigFix = "Not Detected"
}

# Output variables
$output = @{ BIOS_PW = $BIOS_PW; DetectBigFix = $DetectBigFix}
return $output | ConvertTo-Json -Compress