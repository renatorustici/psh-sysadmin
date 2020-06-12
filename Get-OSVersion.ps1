<#
    This script collects the OS version and edition from remote
    Windows computers that are part of the same domain or allow 
    administrative access to them.

    Input: a file named hostList.txt containing each computer 
           name or IP address in each line.

           It's possible to generate the host list file by running a
           command line like the following in the Active Directory computer

           dsquery computer "OU=Servers,DC=domain,DC=com" -o rdn -limit 0 > hostList.txt

           Replace the distinguished name with your own.

    Output: a file named inventory.csv containing the hostname 
           and OS version of each computer.

    Author: Renato Montenegro Rustici

    Feel free to copy, modify, enhance and distribute this script
#>

function Get-RegValue($hostname, $path, $value)
{
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $hostname)
    $key = $reg.OpenSubKey($path)

    return $key.GetValue($value)
}

$report = New-Object System.Data.DataTable
$report.Columns.Add("hostname","string") | Out-Null
$report.Columns.Add("os","string") | Out-Null

$hostList = Get-Content -Path .\hostList.txt

foreach($item in $hostList)
{
    $row = $report.NewRow()

    Write-Host "Collecting inventory from $($item)"

    try
    {
        $row.hostname = Get-RegValue $item "SYSTEM\\CurrentControlSet\\Control\\ComputerName\\ComputerName" "ComputerName"
        $row.os = Get-RegValue $item "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion" "ProductName"
    }
    catch
    {
        $row.hostname = $item
        $row.os = "Error"
    }

    $report.Rows.Add($row)
}

$report | Sort-Object hostname | ft
$report | Export-Csv "inventory.csv" -NoTypeInformation