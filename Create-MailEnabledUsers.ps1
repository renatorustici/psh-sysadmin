param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing the users to update O365 related properties."
    Write-Host "The smtpAddress will be used as the primary SMTP Address, but also in the UPN and Email Address fields."
    Write-Warning "The proxy address by default will be overridden!!!"
    Write-Host "Format: samAccountName,o365ADGroup,smtpAddress"

    exit
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "The path is $($Path)`n"

$users = Get-Content -Path $Path
$failed = New-Object -TypeName "System.Collections.ArrayList"

foreach($user in $users)
{
    $field = $user.split(",")

    $samAccountName = $field[0]
    $o365ADGroup = $field[1]
    $smtpAddress = $field[2]

    Write-Host "   >> Configuring $($samAccountName) ..."

    try 
    {
        Set-ADUser -Identity $samAccountName `
                   -EmailAddress $smtpAddress `
                   -UserPrincipalName $smtpAddress `
                   -replace @{ProxyAddresses="SMTP:$($smtpAddress),SIP:$($smtpAddress)" -Split ","}
    }
    catch 
    {
        Write-Warning $error[0]
        $failed += $samAccountName
    }

    try
    {
        Add-ADGroupMember -Identity $o365ADGroup `
                          -Members $samAccountName
    }
    catch 
    {
        Write-Warning $error[0]
    }
}

if($failed.Count -gt 0)
{
    Write-Host "`nThe following users were NOT update successfully:"

    foreach($user in $failed)
    {
        Write-Host -ForegroundColor red $user
    }
}
else
{
    Write-Host "`nAll AD users were updated successfully."
}


