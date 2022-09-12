function Confirm-PersonalData{
    param(
        [PSCustomObject] $Person
    )

    process{

        if (-not (Confirm-PhoneNumber $Person.Phone)){
            return $false
        }
        if (-not (Confirm-DateOfBirth $Person.Birth)){
            return $false
        }
        $response = Invoke-RestMethod -Uri "http://does.not.exist/api/address/$($Person.Address)"
        return $response.Result
        
    }


}