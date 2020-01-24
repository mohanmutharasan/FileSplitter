#will create this either in form of module or in form of an exe 

param (
  # add all parameters here when calling this module directly
)


function preFileMigrationController{
    # Parameter help description
    param(

    [Parameter(Mandatory=$true)]
    [string]
    $folderPath,
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [ParameterType]
    $groupCount,

    [Parameter(Mandatory=$true)]
    [string]
    $extension,

    [Parameter(Mandatory=$false)]
    [string]
    $namingConvention
    )
    <#what it does
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
}

function sortFilesInFolder {
    <#
    This function will help in sorting the files in a folder . this will be a challenging
    task .
    #>
}

function appendExcelorDB{
    <#
    This function will append the DB log or excel log (Master setup) based on the switch
    #>
}

function VerifyFileName{
    <#
    This function will verify the file naming convetion before moving to a folder location
    #>
}

function Createlog{

}

function fatalerror{
    <#
    in Case of fatal error objects will be disposed here
    #>
}

<#
other helper functions to be mentioned below
#>