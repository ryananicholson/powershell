# Pass in Username to Delete/Create
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$userName
)

# Get the SID of the user
$var = (New-Object System.Security.Principal.NTAccount($userName)).Translate([System.Security.Principal.SecurityIdentifier]).value

# Find the User profile by SID and delete if inactive for 5 days
Get-WmiObject -Class Win32_UserProfile | Where-Object {($_.SID -eq $var) -and (([WMI] '').ConvertToDateTime($_.LastUseTime) -lt ((Get-Date).AddDays(-5)))} | % {$_.Delete()}

# Get the SID of the user
Try {
    $var = (New-Object System.Security.Principal.NTAccount($userName)).Translate([System.Security.Principal.SecurityIdentifier]).value
} Catch {
    echo "USER DOESN'T EXIST!!!"
}

# Find the User profile by SID and delete if inactive for 5 days
Try {
    Get-WmiObject Win32_UserProfile | Where-Object {($_.SID -eq $var)} | % {$_.Delete()}
} Catch {
    echo "SID DOESN'T MAP!!!"
}

# Remove Local User Account
$computerName = $env:COMPUTERNAME
$ADSIComp = [adsi]"WinNT://$computerName"
$ADSIComp.Delete('User',$userName)

# Clean up user directory
$ACL = Get-ACL "C:\Users"
$group = New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
$ACL.SetOwner($group)
Get-ChildItem -Path C:\Users\$userName* -Recurse -Force | Set-Acl -AclObject $ACL
Remove-Item -Force -Recurse C:\Users\$userName*

# Create Local User Account
$ADSIUser = $ADSIComp.Create('User',$userName)
$ADSIUser.SetPassword("12qwaszx!@QWASZX")
$ADSIUser.SetInfo()

# Add user to Users group
$groupName = 'Users'
$ADSIGroup = $ADSIComp.Children.Find($groupName, 'group')
$ADSIGroup.Add(("WinNT://$computerName/$userName"))