# Unit Testing
Auteur: Besseau Léonard
## What ?
A unit test is a test of a specific software component to verify and validates its behaviour to ensure the software is working as expected. The unit covered by the test is generally a function or a method  but can also (rarely) be a module of an application. Unit tests are created before (Test-driven development) or alongside the code during the development. It exist alongside the code it tests in the codebase but is usually not part of the production deployement. There's is also a number of frameworks that exists to manage and execute unit tests.

**In Short**: The goal of an unit test is to test an entity in the code to validate it is performing as expected.

## Why ?
Unit tests are there to help the developer and to speed-up the development process. Here is a few advantages :
 - **Early detection of bug**: Unit-testing allows to detect and pinpoint the origin of a bug.
 - **Regression testing**: Unit-testing allows to detect if a modification in the codebase introduced an unwanted side-effect.
 - **Code validity**: Unit-testing allows a developer to prove its code is working as intended for a given assumption.
 - **Faster reuse**: Unit tested code can be imported alongside its tests in another project. The tests allows to proves the imported code is still working as intented even if it was tweaked.
 - **Alternative documentation**: Unit test can help a new developer understand the basic logic of the components and carry importants information about the intended use of the functions tested. 

## How ?
To use Unit-Testing in a project, a developer write a section of code to test a specific function in a software application. An unit test tries to isolate as much as possible the function it tests in order to validate the behaviour of the tested function and not the underlying functions. Unit tests can be written both for public and private functions.

## Example in Powershell
To illustrate the usage and utility of unit testing, here is an exemple application to show different unit test. To help perform the unit-test we will use [Pester](https://pester.dev/).
### Application Requirement
For this exemple, our application is going to validate the data of a person. A person has a name, a date of birth, a phone number and an address. The constraint are as follows:
 - Date of birth must be in `dd.MM.yyyy` format.
 - Phone number must be a string of exactly 9 number
 - The address is validated by using an external web API
### Project Struture
Our project is strutured as a standard powershell project with the added `Tests` folder:
```
app
 |--Public: The folder containing our public API, the function our module/script offer
 |--Private: The folder containing the functions our public API uses but we don't want to exposr to the user
 |--Tests: The folder containing the test of our functions, It can contains tests for public and/or private functions 
 |--app.psd1
 |--app.psm1
```
Our application has 3 functions, 2 privates:  `Confirm-DateOfBirth`, `Confirm-PhoneNumber` and 1 public: `Confirm-PersonalData`. It will be the function we want to test.
### Setting up the test environnement
As said previously, we will be using Pester to help us with our testing. 
#### Naming conventions
By convention, the `Tests` folder has the same structure as the codebase with the tests having the `.Tests.ps1` extension.
For example, the tests for the function `Confirm-PersonalData` is going to be in the file `Confirm-PersonalData.Tests.ps1`. Generally there is a test file for each function tested but you can separate tests for the same function per category (Unit, Integration, Functional) by adding the category in the extension (`Confirm-PersonalData.TYPE.Tests.ps1`). This naming will also allow you to choose which category of test to execute by launching only the tests of the same type.
#### Test Structure
To test our function, we must first import it. This can be achieved by adding the following at the top of the file:
```Powershell
# At the top of the test file
BeforeAll {
    . $PSScriptRoot/Tested-Function.ps1
}
```
or if you follow the convention, you can also use the generic replace:
```Powershell
BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')# Same directory
    . $PSCommandPath.Replace('.Tests.ps1','.ps1').Replace('\Tests', '') # Same struture in Tests folder
}
```
Now to write a test.

A test is contined in a `Describe` block which represent the function we are testing. Each test we perform inside the functions is inside an `It` block. This block has a small description of the expected result and will either pass or fail depending on the result of the test. the description should be short should allow to understand with a glance what is beeing tested. 
```Powershell
Describe "Invoke-Math" {
    It "adds two number" {
        Invoke-Math -Operation "Addition" 2 3 | Should -Be 5
    }
}
```
You can also group operation based on what you are testing with the `Context` block:
```Powershell
Describe "Invoke-Math" {
    Context "Multiplication"{
        It "multiply" {
            Invoke-Math -Operation "Multiplication" 2 3 | Should -Be 6
        }
    }

    Context "Division"{
        It "divide correctly" {
            Invoke-Math -Operation "Division" 6 3 | Should -Be 2
        }
        It "should throw when dividing by 0" {
            {Invoke-Math -Operation "Division" 6 0} | Should -Throw "Division by zero"
        }
    }

}
```
Some tests case requires some setup. this can be achived with a block `BeforeAll` or `BeforeEach` situated before the tests:
```Powershell
Describe "Invoke-Math" {
    Context "Special-Operation"{
        BeforeAll {
                # Do your setup here
        }
        It "multiply" {
            Invoke-Math -Operation "Special" 2 3 | Should -Be 60000
        }
    }
}
```
If some of your setup requires some cleanup once the test are executed you can use the `AfterAll` or `AfterEach`. Both are guaranted to execute even if the test fails.
#### Testing a simple function
To go back for our example, here is the check used by the `Confirm-phoneNumber` function:
```Powershell
return $Phone -match '^\d{9}$'
```
We can then create our test file `Confirm-phoneNumber.Tests.ps1`  where we will write our tests as follows:
```Powershell
BeforeAll {
    Write-output $PSCommandPath
    . $PSCommandPath.Replace('.Tests.ps1','.ps1').Replace('\Tests', '')
}

Describe "Confirm-PhoneNumber"{
    # Test for a valid case
    It "Returns True for a valid number"{
        Confirm-PhoneNumber -Phone "012345678" | Should -Be $true
    }

    # Test for invalid length
    It "Returns False for an invalid length"{
        Confirm-PhoneNumber -Phone "0123456" | Should -Be $false
        Confirm-PhoneNumber -Phone "01234567890" | Should -Be $false
    }

    # Test for invalid character 
    It "Returns False for invalid character"{
        Confirm-PhoneNumber -Phone "O12345678" | Should -Be $false
    }

    # Not necessary as this is clearly an invalid input and the function is specified to take in a string
    It "Should throw if not a string"{
        {Confirm-PhoneNumber -Phone (Get-Location '.')} | Should -Throw
    }
}
```
If we execute the tests, we can see that everything is passing and if we were to modify the function, for example, by removing the start and end delimiter, we can see that the tests fail which allows us to be sure that the test is working as intended.
#### Testing a complex function
The previous exemple was for a simple function , which has no dependency on another function or another system. `Confirm-PersonalData` on the other hand depends on both the phone and date of birth verification but also on a call to a remote API for the address verification. This poses multiples problems, as we want to test `Confirm-PersonalData` and not his dependency (we want to test the behaviour of this function and are expecting the dependencies to be valid. A valid case for this concern would be that the integration with our tested function is not trivial. In this case, an additional test to verify this can be implemented) or the API could be a paid API or the device on which the testing occurs has no access to the API. To avoid this problem, we can use mocks.

Mocks are a substitution of a function which allows to fake the dependencies of the tested functions. This allows us to replace the tested dependencies by our own version by a version we can modify depending on the case we want to test.
In the following test, we are testing `Confirm-PersonalData` but we are mocking all the dependency.
```Powershell
BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1').Replace('\Tests', '')
}

# We mock the two internal dependecy for all the test, we are going to ignore them for this example
BeforeAll {
    Mock Confirm-DateOfBirth { return $true }
    Mock Confirm-PhoneNumber { return $true }
}


Describe "Confirm-PersonalData" {
    Context "Api Ok" {
        # We create a mock of the call to the API where the response is always valid for this test
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
        # We create a mock of the call to the API where the response is always invalid for this test
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
```
As we can see here mocking is a very powerful tools wich allows us to test the behaviour of our functions in a predictible and repetible way. The `-invoke` parameter allows us to verify the number of a time a function has been called.
## Good practices
Here is a list of good practices that helps making unit testing more effective
- **Document your unit test**: Use the infomration string in the `It` and `Context` block to give a high-level view of what the test is testing. Comment if something is out of the ordinary
- **Deterministic test**: An unit should always have the same result for the same input. Isolate side-effects with mocking if need-be.
- **One test for one case**: A test should test a specific case for the function. If need be create multiple tests. In general, a test should have one assertion or the assertions should test different properties of the same elements.
- **Test with both expected input and unexpected input**: A good test verifies that the code works for a valid input but also for invalid one.
- **Test as you code**: Implement the test in parralel as your function or before implementing your function. This allows you to detect any potential bug faster.
- **Add a test for any reported bug**: Any fix for a reported bug must imply a new test to verify that the bug has been correctly fixed and won't reappear later.
## To go further
### Integration and Functional Testing
Integration testing is another category of test that is performed after all the units tests are succesful. it consist in verifying combining two modules is working as expected.
Functional testing consists of testing the application by verifying the application is behaving as expected by only using the public API.

### Automatic testing and Continuous Integration 
Manual testing is a good tool in a developer arsenal but executing the tests can often be forgotten or the source code and the test can be desynchronized. To this end, perfoming the testing automatically allows to ensure the code is always tested. This automatic testing can be performed by implementing *Continuous Integration*. Continuous Integration is the automation integration of code changes to a codebase. The codebase is stored on a repository where the new code is tested and validated before being added to the codebase.

### Test Driven Development
Test development is a processus in which the functional requirements are first converted into test cases before developing the code. This can described as follows:
- Add the new test.
- Run the all the tests. The new test should faild.
- Write code that accomplish the demanded functionality and pass the test.
- Run all the tests.
- Refactor the function while ensuring that the test still pass.

TTD can be summarized as Red-Green-Refactor, where the test start failing (Red), until the tests pass (Green) followed by the refactor.

### Tests cases in Pester
Similar test can be factorized with the `TestCases` options wich allows to describe the tests input in array an execute the test in the `It` block for each value.
```Powershell
Describe "Invoke-Math" {
    Context "Exponential"{
        It "exponentiate <expected> (<number>)" -TestCases @(
            @{Number = 2, Expected = 7.38905609893}
            @{Number = 3, Expected = 20.0855369232}
        ){
            Invoke-Math -Operation "Exponential" $Number | Should -Be $Expected
        }
    }
}
```

### Tags in Peter
You can add Tag to `Describe`, `Context` and `It`to choose which tests to execute. this can be interressting if a test is particulary slow and you don't want to wait for it every time you launch the tests.

### Code Coverage
TODO
