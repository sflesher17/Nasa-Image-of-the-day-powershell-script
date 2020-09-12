param(
    $month, 
    $day, 
    $year,
    [Parameter(Mandatory=$true)]
    $key
)


#this function is used to get the image from the API 
function get-NasaImage{
    param(
        $outputPath, 
        $fileName, 
        $addString
    )
    #test if the image has already been pulled
    if(test-path "$outputPath\$fileName"){
        write-host "image has already been scraped"
        exit
    }
    if(!(test-path -Path $outputPath)){
        New-Item $outputPath -ItemType Directory 
    }

    $info = invoke-restMethod -Uri "https://api.nasa.gov/planetary/apod?api_key=$key$addString"
    $url = $info.hdurl
    write-host "Fetching from $url" -ForegroundColor Cyan



    #fetch the image
    Invoke-WebRequest $url -OutFile "$outputPath\$fileName"
}

if(!($null -eq $year)){
    $date = "$year-$month-$day"
}else{
    $date = $null
}
$outputPath = "C:\Users\$ENV:USERNAME\pictures\nasaDesktopPics"

#if a file name is passed in, then load that picture into the memory 
if($null -eq $date){
    #today's image is stored in the file name MM_dd_yyyy.jpg
    $fileName = "$(get-date -Format "yyyy-MM-dd" ).jpg"

    get-NasaImage -fileName $fileName -outputPath $outputPath -addString $null 

    set-itemproperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value "$outputPath\$fileName"

}else{
    if(!(test-path "$outputPath/$date.jpg")){
        write-host "The date you are looking for has not been loaded onto this device" -ForegroundColor red
        write-host "Loading the image" -ForegroundColor red 

        get-NasaImage -outputPath $outputPath -fileName "$date.jpg" -addString "&date=$date"
        write-host "Finished" -ForegroundColor green
    }
    set-itemproperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value "$outputPath/$date.jpg"
}


#update the desktop
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True