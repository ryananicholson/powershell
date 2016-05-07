# Pass in Username to Delete/Create
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$userName
)

# Create Local User Account
$computerName = $env:COMPUTERNAME
$ADSIComp = [adsi]"WinNT://$computerName"
$ADSIUser = $ADSIComp.Create('User',$userName)
$ADSIUser.SetPassword("12qwaszx!@QWASZX")
$ADSIUser.SetInfo()

# Add user to Users group
$groupName = 'Users'
$ADSIGroup = $ADSIComp.Children.Find($groupName, 'group')
$ADSIGroup.Add(("WinNT://$computerName/$userName"))