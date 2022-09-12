BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Tests', '')
}

BeforeAll {

    Mock Confirm-DateOfBirth { return $true }
    Mock Confirm-PhoneNumber { return $true }
}


Describe "Confirm-PersonalData" {
    Context "Api Ok" {
        BeforeAll {
            Mock Invoke-RestMethod {
                return @{
                    Result = $true
                }
            }
        }
        It "Returns True for a valid person" {
            $Person = [PSCustomObject]@{
                Name    = "Donald"
                Phone   = "012345678"
                Birth   = "13.03.1942"
                Address = "DonaldVille"
            }
            Confirm-PersonalData -Person $Person | Should -Be $true
            Should -Invoke -CommandName Confirm-DateOfBirth -Times 1
            Should -Invoke -CommandName Confirm-PhoneNumber -Times 1
        }
    }

    Context "Api Not Ok" {
        BeforeAll {
            Mock Invoke-RestMethod {
                return @{
                    Result = $false
                }
            }
        }
        It "Returns True for a valid person" {
            $Person = [PSCustomObject]@{
                Name = "Mickey"
                Phone = "019282721"
                Birth = "05.12.1901"
                Address = "MickeyVille"
            }
            Confirm-PersonalData -Person $Person | Should -Be $false
            Should -Invoke -CommandName Confirm-DateOfBirth -Times 1
            Should -Invoke -CommandName Confirm-PhoneNumber -Times 1
        }
    }

}