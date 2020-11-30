param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing the group and the respective members."
    Write-Host "Format: GroupSMTPAddress,MemberSMTPAddress"

    exit
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "The path is $($Path)"

$relationships = Get-Content -Path $Path
$failed = New-Object -TypeName "System.Collections.ArrayList"

foreach($relationship in $relationships)
{
    $field = $relationship.split(",")

    $groupSMTPAddress = $field[0]
    $memberSMTPAddress = $field[1]

    Write-Host "   >> Configuring $($groupSMTPAddress) ..."

    try 
    {
        Add-UnifiedGroupLinks -Identity $groupSMTPAddress `
                            -LinkType Members `
                            -Links $memberSMTPAddress
    }
    catch 
    {
        Write-Warning $error[0]
        $failed += $groupSMTPAddress
    }                 
}

if($failed.Count -gt 0)
{
    Write-Host "`nThe following groups were NOT updated successfully:"

    foreach($group in $failed)
    {
        Write-Host -ForegroundColor red $group
    }
}
else
{
    Write-Host "`nAll groups were updated successfully."
}
