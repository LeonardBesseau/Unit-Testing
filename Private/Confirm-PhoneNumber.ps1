function Confirm-PhoneNumber{
    param(
        [Parameter(Mandatory=$true)]
        [System.String] 
        $Phone
    )

    process{
        return $Phone -match '^\d{9}$'
    }
}