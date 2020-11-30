param($Path)

if ($null -eq $Path)
{
    Write-Host "Please, provide the file containing the users."
    Write-Host "Format: ExternalSMTPAddress,MSOnlineID,Alias"
    Write-Host "        * By default, the SMTP address will be used for the display name"

    exit
}

$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "The path is $($Path)"

$contacts = Get-Content -Path $Path
$failed = New-Object -TypeName "System.Collections.ArrayList"
$reallyStrongRandomPassword = ConvertTo-SecureString -String "-&u!£mis4d9123!1fSp2&" -AsPlainText -Force

foreach($contact in $contacts)
{
    $field = $contact.split(",")

    $smtpAddress = $field[0]
    $name = $field[0]
    $MSOnlineID = $field[1]
    $alias = $field[2]

    Write-Host "   >> Configuring $($smtpAddress) ..."

    try 
    {
        New-MailUser -Name $name `
                    -ExternalEmailAddress $smtpAddress `
                    -Alias $alias `
                    -MicrosoftOnlineServicesID $MSOnlineID `
                    -Password $reallyStrongRandomPassword 
    }
    catch 
    {
        Write-Warning $error[0]
        $failed += $smtpAddress
    }                 
}


if($failed.Count -gt 0)
{
    Write-Host "`nThe following contacts were NOT created successfully:"

    foreach($contact in $failed)
    {
        Write-Host -ForegroundColor red $contact
    }
}
else
{
    Write-Host "`nAll contacts were created successfully."
}
