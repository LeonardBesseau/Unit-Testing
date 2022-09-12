BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1').Replace('\Tests', '')
}

Describe "Confirm-PhoneNumber"{
    It "Returns True for a valid number"{
        Confirm-PhoneNumber -Phone "012345678" | Should -Be $true
    }

    It "Returns False for an invalid length"{
        Confirm-PhoneNumber -Phone "0123456" | Should -Be $false
        Confirm-PhoneNumber -Phone "01234567890" | Should -Be $false
    }

    It "Returns False for invalid character"{
        Confirm-PhoneNumber -Phone "O12345678" | Should -Be $false
        Confirm-PhoneNumber -Phone "1223Oaods012345678" | Should -Be $false
    }

    # Not necessary as this is clearly an invalid input and the function is specified to take in a strinf
    It "Should throw if not a string"{
        {Confirm-PhoneNumber -Phone (Get-Location '.')} | Should -Throw
    }
}