
#Collects user input based off template sent from HR 
#This will not collect lines with less than 2 characters to avoid collecting empty lines.
#This will also ensure there are at least 5 lines since we need at least that many parameters.
Function GetUserInput {
    $InputParams = [System.Collections.ArrayList]@()
    Write-Host("Enter the user's information (Enter 2 blank lines to stop collecting input):")
    $UserInput = $null
    $Flag = 0 #Keeps track of blank lines 1 means there was a blank line last iteration, 2 consecutive blank lines will end the loop.
    while(1) {
        $UserInput = Read-Host
        if ($UserInput.Length -lt 2) { #this is an empty line
            if ($Flag -eq 1) { #if flag already set to 1, we encountered a blank line last iteration
                break #exit the loop 2 consecutive blank lines
            }
            else {
                $Flag = 1
                continue #don't add an empty line to the array
            }
        }
        else { #if curret line is not a blank lines.
            $Flag = 0 #reset flag
        }
        $InputParams.Add($UserInput) | Out-Null #prevent adding integers to the arraylist

    }
    if($InputParams.Count -lt 4) {
        Write-Host "Not enough input given. Restarting program...."
        Start-Sleep -s 1.5
        Clear-Host
        GetUserInput #collect input again.
    }
    return $InputParams
}

#Ensures input given is in a valid format. After this function is run, there should only be 5 Entries in the array list
#Input to this function must be given in the correct order. The program doesn't yet parse the data out of order. 
#Input must be given in the format shown in lines 40-44. 
#Example entries in the arraylist will look like this
#0: Dept / Location: [data]
#1: Employee Number:[data]
#2: User Name:[data]
#3: Preferred Name for Email: [data]
#4: Job Title: [data]
Function ValidateInput ($UserInfoArgs) { 

    for ($i = 0; $i -lt $UserInfoArgs.Count; $i++) { #If a line is not valid or doesn't contain what we are looking for. Remove it from the list entirely and decrement counter
        if ($i -eq 0 -and ($UserInfoArgs[$i] -Match "Dept" -eq 0 -or $UserInfoArgs[$i] -Match "Location" -eq 0)) { #validate first line
            $UserInfoArgs.Remove($UserInfoArgs[$i])
            if ($i -eq $UserInfoArgs.Count) {
                Write-Host "Never found Location Number... Check format and try again"
                Start-Sleep 1.5
                Clear-Host
                break
            }
            $i--
            continue
        }
        if ($i -eq 1 -and ($UserInfoArgs[$i] -Match "Employee Number" -eq 0)) { #validate second line
            $UserInfoArgs.Remove($UserInfoArgs[$i])
            if ($i -eq $UserInfoArgs.Count) {
                Write-Host "Never found Employee Number... Check format and try again"
                Start-Sleep 1.5
                Clear-Host
                break
            }
            $i--
            continue
        }
        if ($i -eq 2 -and ($UserInfoArgs[$i] -Match "User Name" -eq 0)) { #validate third line
            $UserInfoArgs.Remove($UserInfoArgs[$i])
            if ($i -eq $UserInfoArgs.Count) {
                Write-Host "Never found User Name... Check format and try again"
                Start-Sleep 1.5
                Clear-Host
                break
            }
            $i--
            continue
        }
        if ($i -eq 3 -and ($UserInfoArgs[$i] -Match "Preferred Name for Email" -eq 0)) { #validate fourth line
            $UserInfoArgs.Remove($UserInfoArgs[$i])
            if ($i -eq $UserInfoArgs.Count) {
                Write-Host "Never found Prefered name for Email... Check format and try again"
                Start-Sleep 1.5
                Clear-Host
                break
            }
            $i--
            continue
        }
        if ($i -eq 4 -and ($UserInfoArgs[$i] -Match "Job Title" -eq 0)) { #validate fifth line
            $UserInfoArgs.Remove($UserInfoArgs[$i])
            if ($i -eq $UserInfoArgs.Count) {
                Write-Host "Never found Job Title... Check format and try again"
                Start-Sleep 1.5
                Clear-Host
                break
            }
            $i--
            continue
        }
        elseif ($i -gt 4) {
            $UserInfoArgs.Remove($UserInfoArgs[$i]) #remove the line since these are the only 5 that will enter data into AD.
            $i--
        }                
    }
    return $UserInfoArgs
}

#Interprets the Validated Input and puts them in a new arraylist with the actual parameters to be passed.
#This will strip all text that is not the parameter. It will also set the User Name to be the Preferred name for email if that line wasn't empty
#Example input after this function would be '//' is just a way to show what the data corresponds to. It is not included in the array
#0: [data]          //Location Number
#1: [data]          //Employee Number
#2: [data]          //User Name
#3: [data]          //Preferred Name for Email (may be empty)
#4: [data]          //Job Title
Function UserInputToParameters ($UserInfoArgs) { 
    $ModifiedParams = [System.Collections.ArrayList]@()
    for ($i = 0; $i -lt $UserInfoArgs.Count; $i++) {
        if ($i -eq 0) {
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace(" ","") #Reomve all spaces 
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace("Dept/Location:","") #remove text before location num
            $UserInfoArgs[$i] = $UserInfoArgs[$i].SubString(0,3) #take only next 3 chars
            if ($UserInfoArgs[$i].Length -ne 3 -or $UserInfoArgs[$i] -match "^\d+$" -eq 0) { #checks for length and ensures it is numeric.
                Write-Host ("ERROR, Location Code is not 3 digits or contains non numeric characters. Enter the correct Location Code:`n")
                $UserInfoArgs[$i] = Read-Host
                $ModifiedParams.Add($UserInfoArgs[$i]) | Out-Null #prevent adding integers to the arraylist
                $i-- #decrement i so we will validate this again.
                continue
            }
            else{
                $ModifiedParams.Add($UserInfoArgs[$i]) | Out-Null #prevent adding integers to the arraylist
            }
        }
        if ($i -eq 1) {
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace(" ","") #Reomve all spaces
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace("EmployeeNumber:","")
            if ($UserInfoArgs[$i].Length -ne 4 -or $UserInfoArgs[$i] -match "^\d+$" -eq 0) { #checks for length and ensures it is numeric.
                Write-Host ("ERROR, Employee ID is not 4 digits or contains non numeric characters. Enter the correct Employee ID:`n")
                $UserInfoArgs[$i] = Read-Host 
                $ModifiedParams.Add($UserInfoArgs[$i]) | Out-Null #prevent adding integers to the arraylist
                $i-- #decrement i so we will validate this again.
                continue
            }
            else {
                $ModifiedParams.Add($UserInfoArgs[$i]) | Out-Null #prevent adding integers to the arraylist
            }
            
        }
        if ($i -eq 2) {
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace("User Name: ","")
            $ModifiedParams.Add($UserInfoArgs[$i]) | Out-Null #prevent adding integers to the arraylist
        }
        if ($i -eq 3) {
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace(" ","") #Reomve spaces if they exist
            if ($UserInfoArgs[$i] -eq "PreferredNameforEmail:") {
                continue
            }
            else {
                $LengthAfterDotRemoval = $UserInfoArgs[$i].replace(".","").Length
                if ($UserInfoArgs[$i] -match "@wilco.coop" -eq 0 -or ($UserInfoArgs[$i].Length - ($LengthAfterDotRemoval) -ne 2)) { #ensures there are 2 periods, and there is an @wilco.coop
                    Write-Host ("ERROR, Invalid Format to Preferred Name for Email.`nFormat is: FirstName.LastName@wilco.coop`nEnter preferred name for email:`n")
                    $UserInfoArgs[$i] = Read-Host 
                    $ModifiedParams[2] = $UserInfoArgs[$i] #prevent adding integers to the arraylist
                    $i-- #decrement i so we will validate this again.
                    continue
                }
                else {
                    $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace("PreferredNameforEmail:","")
                    $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace("."," ") #Replace . with space to fit name format    
                    $UserInfoArgs[$i] = $UserInfoArgs[$i].SubString(0, $UserInfoArgs[$i].IndexOf('@'))
                    $ModifiedParams[2] = $UserInfoArgs[$i] # set name to be the email name for easier AD modifications after the script is ran                
                }
            }
        }
        if ($i -eq 4) {
            $UserInfoArgs[$i] = $UserInfoArgs[$i].Replace("Job Title: ","")
            $ModifiedParams.Add($UserInfoArgs[$i]) | Out-Null #prevent adding integers to the arraylist
            break; 
        }
    }
    if ($ModifiedParams.Count -ne 4) {
        Write-Host "Missing at least one of the required lines"
        Start-Sleep 1.5
        Clear-Host
        return $null
    }
    return $ModifiedParams
}

#Prints output of the 4 variables obtained from the earlier steps. 
#Returns Boolean that indicates if the input looks correct to the user.
Function ConfirmInputCorrect($ModifiedParams) {
    while(1) {
        Write-Host("Data Collected:`n================`n ")
        for ($i = 0; $i -lt 4; $i++) {
            switch ($i) {
                0 { $ToPrint = $ModifiedParams[$i]
                    Write-Host("Location Code:$ToPrint`n")}
                1 { $ToPrint = $ModifiedParams[$i]
                    Write-Host("Employee ID:$ToPrint`n")}
                2 { $ToPrint = $ModifiedParams[$i]
                    Write-Host("User Name:$ToPrint`n")}
                3 { $ToPrint = $ModifiedParams[$i]
                    Write-Host("Job Title:$ToPrint`n")}
                default { Write-Host("This won't ever happen")}
            }
        }
        $UserInput = Read-Host -Prompt ("Is this data correct? (y/n)")
        if ($UserInput -eq 'y' -or $UserInput -eq 'Y') {
            break
        }
        if ($UserInput -eq 'n' -or $UserInput -eq 'N') {
            break
        }
        Clear-Host
        Write-Host("Invalid Input. Enter (y/n)`n")
    }
    return $UserInput
} 

#Main function -- Don't need this to be a function. Just for my organization
Function Main { 
    $Proceed = 'N'
    while($Proceed -ne 'y' -or $Proceed -ne 'Y') { #loop forever until user says input is correct
        [System.Collections.ArrayList]$UserInfoData = GetUserInput #collects raw input, ignores blank & irrelevant lines. It also ensures there are at least 4 lines
        if ($UserInfoData.Count -lt 3) {
            continue #get user input again
        }
        $UserInfoData = ValidateInput($UserInfoData) #deletes lines that are not relevant and ensures there are 4 lines that contain the variables we want
        [System.Collections.ArrayList]$ModifiedParams = UserInputToParameters($UserInfoData) #Parses the data and stores the 4 variables to pass to the new user script
        if ($null -eq $ModifiedParams) { #this becomes null if there are not 4 lines that contain the variables we want.
            continue #get user input again.
        }
        $Proceed = ConfirmInputCorrect($ModifiedParams) #get new value for proceed y if user selects y, n if user selects n. Will loop until 
        if ($Proceed -eq 'y' -or $Proceed -eq 'Y') {
            $Arg1 = $ModifiedParams[0]
            $Arg2 = $ModifiedParams[1]
            $Arg3 = $ModifiedParams[2]
            $Arg4 = $ModifiedParams[3]
            $ArgumentList = "-LocNum $Arg1 -EmpNum $Arg2 -Name `"$Arg3`" -JobTitle `"$Arg4`""
            $ScriptPath= $PSScriptRoot+"\test.ps1"
            Invoke-Expression "& `"$ScriptPath`" $ArgumentList" #jump to new script, passing the validated data
            return
        }
        elseif ($Proceed -eq 'N' -or $Proceed -eq 'n') { 
            Clear-Host
            continue
        }
        else {
            Write-Host "Proceed is not y or n...something is wrong...`nExiting"
            cmd /c pause
            exit
        }    
    }
}

Main #call main function
cmd /c pause
exit