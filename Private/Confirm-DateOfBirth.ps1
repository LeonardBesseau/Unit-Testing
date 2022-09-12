function Confirm-DateOfBirth{
    param(
        [Parameter(Mandatory=$true)]
        [System.String] 
        $Date
    )

    process{
        try {
            $null = ([DateTime]::ParseExact($Date, "dd.MM.yyyy", [System.Globalization.CultureInfo]::InvariantCulture))
            return $true
        }
        catch {
            return $false
        }
    }
}