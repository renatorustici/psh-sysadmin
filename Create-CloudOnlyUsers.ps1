param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing the users."
    Write-Host "Format: SMTPAddress,FirstName,LastName,Password,License"

    exit
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "The path is $($Path)"

$users = Get-Content -Path $Path
$failed = New-Object -TypeName "System.Collections.ArrayList"

foreach($user in $users)
{
    $field = $user.split(",")

    $smtpAddress = $field[0]
    $firstName = $field[1]
    $lastName = $field[2]
    $password = $field[3]
    $license = $field[4]

    # Creating the user

    $displayName = ""

    if($lastName.Length -eq 0)
    {
        $displayName = $firstName
    }
    else
    {
        $displayName = "$($firstName) $($lastName)"
    }

    Write-Host "   >> Configuring $($smtpAddress) ..."

    try 
    {
        New-MsolUser -DisplayName $displayName `
                    -FirstName $firstName `
                    -LastName $lastName `
                    -UserPrincipalName $smtpAddress `
                    -UsageLocation BR `
                    -PreferredLanguage "pt-BR" `
                    -LicenseAssignment $license `
                    -Password $password #`
                    #-ForceChangePassword $false
    }
    catch 
    {
        Write-Warning $error[0]
        $failed += $smtpAddress
    }                 
}

if($failed.Count -gt 0)
{
    Write-Host "`nThe following users were NOT created successfully:"

    foreach($user in $failed)
    {
        Write-Host -ForegroundColor red $user
    }
}
else
{
    Write-Host "`nAll MS 365 users were created successfully."
}

