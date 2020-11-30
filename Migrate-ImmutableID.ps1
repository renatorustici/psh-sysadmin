param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing both, the AD users and the 365 UPN."
    Write-Host "Format: samAccountName,o365Upn"

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
    $o365Upn = $field[1]

    Write-Host "   >> Configuring $($samAccountName) ..."

    try
    {
        $imuid = [system.convert]::ToBase64String((Get-ADUser $samAccountName).objectGUid.ToByteArray())
        Set-MsolUser -UserPrincipalName $o365Upn `
                     -ImmutableId $imuid `
                     -ErrorAction Stop
    }
    catch
    {
        Write-Warning $error[0]
        $failed += $samAccountName
    }
}

if($failed.Count -gt 0)
{
    Write-Host "`nThe following users were NOT updated successfully:"

    foreach($user in $failed)
    {
        Write-Host -ForegroundColor red $user
    }
}
else
{
    Write-Host "`nAll cloud users were updated successfully."
}

