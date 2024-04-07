### WARNING: This script will not require user to change password at next logon

# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the path to the CSV file
$csvPath = "C:\path\to\your\csv\file.csv"

# Read the CSV file
$csvData = Import-Csv -Path $csvPath

# Loop through each row in the CSV
foreach ($row in $csvData) {
    # Get the samaccountname and password from the current row
    $samaccountname = $row.samaccountname
    $password = $row.password

    # Find the user in Active Directory
    $user = Get-ADUser -Filter "samaccountname -eq '$samaccountname'"

    # If the user is found, reset their password
    if ($user) {
        $user | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
        $user | Set-ADUser -ChangePasswordAtLogon $false
        Write-Host "Password reset for user: $($user.samaccountname)"
    } else {
        Write-Host "User not found: $samaccountname"
    }
}