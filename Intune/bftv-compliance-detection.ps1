# Check for BIOS Password
$BIOS_test = Get-CimInstance -Namespace root/dcim/sysman/wmisecurity -ClassName PasswordObject | Where-Object NameId -EQ "Admin" | Select-Object -ExpandProperty IsPasswordSet
$BIOS_PW = $false	
if ($BIOS_test)
{
	$BIOS_PW = $true
}

# Collect installed software
$InstalledSoftware = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*

# Check if BigFix is Installed
if ($InstalledSoftware.DisplayName -like "BigFix Client") {
	$DetectBigFix = "Detected"
}
else {
	$DetectBigFix = "Not Detected"
}

# Check if Trellix is Installed
if ($InstalledSoftware.DisplayName -like "Trellix Endpoint Security*") {
	$DetectTrellix = "Detected"
}
else {
	$DetectTrellix = "Not Detected"
}

# Output variables
$output = @{ BIOS_PW = $BIOS_PW; DetectBigFix = $DetectBigFix; DetectTrellix = $DetectTrellix}
return $output | ConvertTo-Json -Compress