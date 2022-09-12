BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1').Replace('\Tests', '')
}

Describe "Confirm-DateOfBirth"{
    It "Returns True for a valid date"{
        Confirm-DateOfBirth -Date "01.12.2956" | Should -Be $true
    }

    It "Returns False for an invalid format"{
        Confirm-DateOfBirth -Date "01-12.1976" | Should -Be $false
        Confirm-DateOfBirth -Date "Not a date" | Should -Be $false
    }
}