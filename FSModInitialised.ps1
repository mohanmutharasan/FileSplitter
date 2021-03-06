#will create this either in form of module or in form of an exe 

param (
  # add all parameters here when calling this module directly
)

#region libraries to be imported (dependancy management)
function appendexcel{
    param(
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]
        $fileName,
    
        [Parameter(Mandatory=$true)]
        [System.Array]
        $inputData,
    
        [Parameter(Mandatory=$true)]
        [string]
        $columnIndex
    )
    
    
    process{
        if (Test-Path -Path $fileName){
            $inputData  | Export-Excel -Path  $fileName -WorksheetName "MasterData" -StartColumn $columnIndex -Show -Append
        }
        else{ # creating master file for the first time
            #region add column to excel
            #creating PSObject for column names
            $columNames = New-Object -TypeName PSObject
            $d = [ordered]@{Name="";group="";Size=""}
            $columNames| Add-Member -NotePropertyMembers $d -TypeName Asset
            $columNames | Export-Excel -Path  $fileName -WorksheetName "MasterData"  #add the column name to the new file 
            
            #endregion
            $inputData  | Export-Excel -Path  $fileName -WorksheetName "MasterData" -StartColumn $columnIndex -AutoSize  -Append #append the first data
        }
    }
    
    }
function SortedFilesInFolder
 {
    <#
    This function retunrs all the childitems in a sorted format in an array.
    task .
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]
        $folderPath,

        [Parameter(Mandatory=$true)]
        [string]
        $Extension
        )
    $sortedArray = Get-ChildItem -Path $folderPath | Where-Object Extension -EQ $Extension | Select-Object -ExpandProperty  Name | Sort-Object -Property Name -Descending   
    return $sortedArray
 }

function MoveFiles{

    # this function will move files based on sortedarray received
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $folderPath, 
        
        [Parameter(Mandatory=$true)]
        [System.Array]
        $fileArray,

        [Parameter(Mandatory=$true)]
        [System.Array]
        $outputPath,

        [Parameter(Mandatory=$true)]
        [System.Array]
        $folderIndex

    )
    foreach ($tempFiles in $fileArray)
    {
     $currentFile = "$folderPath/$tempFiles" #current file in the directory
     $destPath = "$outputPath/Premigration_$folderIndex/$tempFiles"
     [System.IO.File]::Copy($currentFile,$destPath) | Out-Null #file copied to the new location
    }


}
# this function will do initial migration test , like path check , folder creation and then pass the controller to other helper functions
function PreFileMigrationController{
    # Parameter help description
    param(

    [Parameter(Mandatory=$true)]
    [string]
    $folderPath,
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [int]
    $groupCount,

    [Parameter(Mandatory=$true)]
    [string]
    $extension,

    [Parameter(Mandatory=$false)]
    [string]
    $namingConvention,

    [Parameter(Mandatory=$true)]
    [string]
    $outputPath
    )
    <# what it does
    fetch following parameters as input 

    1. Migration file path
    2. group Count
    3. Extension for separation
    4. Excel output
    5 .naming convention validtion (second release)

     task1 - sort files on the basis of name
     task2 - create folder 1.. n (n = (total files)/($groupSize) .. take ceiling value)
     task3 - take 1st 1.. $group size file and move to the folder 1 ... 
     task3 - create slave ex at each fol
     task4 - create log  at master
     task5 - create final db or ex at master
 
     Side note - refer importExcel module as well as PSCache for optimisation
    #>

    begin{
    #region test paramter value
     #endregion
    # check if folder is present in the machine
    if (!(test-path -path $folderPath)){
        #call Fatal error 
        fatalerror
    }
    
     $totalFileCount = (Get-ChildItem -Path $folderPath | Select-Object Extension | Where-Object Extension -EQ "$extension").Count
     # when the group count is less than or equal to the total files in the fodlers
     if ($groupCount -ge $totalFileCount){
         $totalFolders = 1 
     }
     else{
         
         $totalFolders = [int][math]::Ceiling(($totalFileCount/$groupCount)) # taking ceiling value since we need to have an extra folder for remaining files
     }
    }
    process{
          #create the child FD

          $sortedFileArray = sortedFilesInFolder  -folderPath $folderPath -Extension $extension # sortedarray of files
          $tempFolderCount = $totalFolders 
          #region temp folder creation in the output path
          while ($tempFolderCount -gt 0)
          {
            $tempFolderName = "Premigration_$tempFolderCount"
            New-Item -ItemType Directory -Path $outputPath -Name $tempFolderName | Out-Null
            $tempFolderCount -= 1 #reducing the count for subsequent folder creation
          }
          Write-Host "Folders Created" -ForegroundColor Green 
          #endregion
          #region extracting subarray and passing to moveFile
          $initialIndex = 0
          $destfolderIndex = 0
          while ($initialIndex -le $sortedFileArray.count)
          {
          $destfolderIndex += 1
          $finalIndex = $initialIndex + $groupCount - 1
          $subFileArray = @()
          $subFileArray = $sortedFileArray[$initialIndex..$finalIndex] # extracted subsection to move to nth folder
          MoveFiles -folderPath $folderPath -outputPath $outputPath -fileArray $subFileArray -folderIndex $destfolderIndex # move file called to move the section of files
          $initialIndex += $groupCount # moving the initial index pointer to current index of the array
          
          #data chunk to be transmitted for excel of sql data addition
          appendexcel -fileName "$outputPath/MasterData.xlsx" -inputData $subFileArray -columnIndex 1 

          }
          #endregion
    }
    end{

    }

}

#parameters exposed to end users
preFileMigrationController -folderPath "C:\Users\t.b.ahmed\Desktop\Automation" -groupCount 3 -extension ".pdf" -outputPath "C:\Users\t.b.ahmed\Desktop\outputPath"

Write-Host "1st phase completed" -ForegroundColor Green



function appendsql{

}


function VerifyFileName{
    <#
    This function will verify the file naming convetion before moving to a folder location
    #>
}

function Createlog{
<#
Create a global log path

#>
param(
    
)

}

function fatalerror{
    <#
    in Case of fatal error objects will be disposed here and the execution will stop
    #>
}

<#
other helper functions to be mentioned below
#>

