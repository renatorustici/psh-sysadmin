<#
    This script generates a report to aid planning
    of VM migrations between storage locations or simply to
    provide a report showing the location, type and size
    of the VM's VHDs.
    Author: Renato Montenegro Rustici
    October/2020
    Feel free to copy, modify, enhance and distribute this scrip
#>

$report = New-Object System.Data.DataTable
$report.Columns.Add("hostname","string") | Out-Null
$report.Columns.Add("cpu","string") | Out-Null
$report.Columns.Add("ram","string") | Out-Null
$report.Columns.Add("path","string") | Out-Null
$report.Columns.Add("type","string") | Out-Null
$report.Columns.Add("filesize","string") | Out-Null
$report.Columns.Add("maxsize","string") | Out-Null

$clusterNodes = Get-ClusterNode | Select-Object Name 

ForEach($node in $clusterNodes)
{
    $vms = Get-VM -ComputerName $node.Name

    ForEach($vm in $vms)
    {
        $cpu = Get-VMProcessor -VMName $vm.Name -ComputerName $node.Name
        $disks = Get-VHD -VMId $vm.VMId -ComputerName $node.Name

        ForEach($disk in $disks)
        {
            $row = $report.NewRow()

            $row.hostname = $vm.Name
            $row.cpu = $cpu.Count
            $row.ram = [Math]::Round($vm.MemoryAssigned/[Math]::Pow(1024, 3), 1)
            $row.path = $disk.Path
            $row.type = $disk.VhdType
            $row.filesize = [Math]::Round($disk.FileSize/[Math]::Pow(1024, 3))
            $row.maxsize = $disk.Size/[Math]::Pow(1024, 3)

            $report.Rows.Add($row)
        }
    }
}
$report | Format-Table
$report | Export-Csv "Inventory.csv" -Delimiter ";" -NoTypeInformation