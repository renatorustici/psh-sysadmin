param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing the groups."
    Write-Host "Format: DisplayName,SMTPAddress,Owner"

    exit
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "The path is $($Path)"

$groups = Get-Content -Path $Path
$failed = New-Object -TypeName "System.Collections.ArrayList"

foreach($group in $groups)
{
    $field = $group.split(",")

    $displayName = $field[0]
    $smtpAddress = $field[1]
    $alias = ($field[1].Split("@"))[0]
    $owner = $field[2]

    Write-Host "   >> Configuring $($smtpAddress) ..."

    try 
    {
        New-UnifiedGroup -AccessType Private `
                        -Language pt-BR `
                        -RequireSenderAuthenticationEnabled $false `
                        -PrimarySmtpAddress $smtpAddress `
                        -DisplayName $displayName `
                        -Alias $alias `
                        -Owner $owner
    }
    catch 
    {
        Write-Warning $error[0]
        $failed += $smtpAddress
    }                 
                
}

if($failed.Count -gt 0)
{
    Write-Host "`nThe following groups were NOT created successfully:"

    foreach($group in $failed)
    {
        Write-Host -ForegroundColor red $group
    }
}
else
{
    Write-Host "`nAll groups were created successfully."
}
