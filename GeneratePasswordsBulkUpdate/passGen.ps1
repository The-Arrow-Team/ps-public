function Get-RandomPass {
    # Read the word bank from the file
    Write-Host "Reading the word bank from file..."
    $Bank = Get-Content .\WordBank.txt

    # Function to generate a password
    function genPassword {
        $Words = @()
        while ($Words.Count -lt 2) {
            $Word = Get-Random -InputObject $Bank
            $Word = $Word.Substring(0,1).ToUpper() + $Word.Substring(1,$Word.Length-1)
            $Words += $Word
        }

        # Combine the words into a single string
        $CombinedWords = -join $Words

        # Generate a random number
        $Number = "{0:d3}" -f (Get-Random -Minimum 1 -Maximum 999)

        # Select a random special character
        $Special = [char[]]"@#$!%&" | Get-Random

        # Construct the password
        $Password = $CombinedWords + $Number + $Special

        return $Password
    }

    # Number of passwords to generate
    $numPasswords = 1000

    # Path to the output CSV file
    $outputCsvPath = ".\outPasswords.csv"

    # Initialize an array to hold the passwords
    $passwords = @()

    # Loop to generate the specified number of passwords
    for ($i = 0; $i -lt $numPasswords; $i++) {
        Write-Host "Generating password $($i + 1) of $numPasswords..."

        $validPassword = $false

        # Try to generate a valid password
        while (-not $validPassword) {
            $Password = genPassword
            if ($Password.Length -ge 12 -and $Password.Length -le 16) {
                $validPassword = $true
            }
        }

        # Add the password to the array
        $passwords += [PSCustomObject]@{
            Password = $Password
        }

        # Output progress to the console
        Write-Host "Passwords generated: $($i + 1) / $numPasswords"
    }

    # Export the passwords to a CSV file
    Write-Host "Exporting passwords to CSV file..."
    $passwords | Export-Csv -Path $outputCsvPath -NoTypeInformation

    Write-Host "Password generation process completed. Output saved to $outputCsvPath."
}

# Call the function to generate passwords and save them to a CSV file
Get-RandomPass