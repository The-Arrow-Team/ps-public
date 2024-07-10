### WARNING: This script will NOT require user to change password at next logon

# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the path to the CSV files
$pwCsvPath = ".\outPasswords.csv"
$outputCsvPath = ".\newCreds.csv"

# Read the CSV file
$passwords = Import-Csv -Path $pwCsvPath

# Specify the security group name
$groupName = "YourSecurityGroupName"

# Get the members of the specified security group
$groupMembers = Get-ADGroupMember -Identity $groupName

# Initialize an array to hold the output data
$outputData = @()

# Loop through each member in the group
for ($i = 0; $i -lt $groupMembers.Count; $i++) {
    # Get the current group member
    $member = $groupMembers[$i]

    # Ensure the password index is within bounds of the password list
    if ($i -lt $passwords.Count) {
        $password = $passwords[$i].password

        # Reset the password for the current member
        Set-ADAccountPassword -Identity $member -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
        Set-ADUser -Identity $member -ChangePasswordAtLogon $false

        Write-Host "Password reset for user: $($member.UserPrincipalName)"

        # Add the user and password to the output data
        $outputData += [PSCustomObject]@{
            UserPrincipalName = $member.UserPrincipalName
            Password = $password
        }
    } else {
        Write-Host "Not enough passwords in the CSV file for all group members."
        break
    }
}

# Export the output data to a new CSV file
$outputData | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Password reset process completed. Output saved to $outputCsvPath."
