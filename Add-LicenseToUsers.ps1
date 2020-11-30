param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing the users and the SKUs."
    Write-Host "Format: ms365Upn,sku"

    exit
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "The path is $($Path)`n"

$users = Get-Content -Path $Path
$failed = New-Object -TypeName "System.Collections.ArrayList"

foreach($user in $users)
{
    $field = $user.split(",")

    $ms365Upn = $field[0]
    $sku = $field[1]

    Write-Host "   >> Configuring $($ms365Upn) ..."

    try 
    {
        Set-MsolUserLicense -UserPrincipalName $ms365Upn `
                            -AddLicenses $sku `
                            -ErrorAction Stop
    }
    catch 
    {
        Write-Warning "!!! $($error[0])"
        $failed += $ms365Upn
    }
}

Write-Host "falhas $($failed.Count)"

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
    Write-Host "`nAll AD users were updated successfully."
}


