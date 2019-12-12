Write-Host "Hi there!"
$SourceDirectory = "C:\temp"
$FileFilter = "*.txt"
$SourceEncodingName = "windows-1251"
$TargetEncodingName = "utf-8"
$TargetEncodingCode = "UTF8"
$Confirmation = "Y"
# Read-Host function wrapper to support default value
Function Read-Host-Default([String]$Prompt, [String]$DefaultValue) {
	$ReadResult = $DefaultValue
    $Value = Read-Host "$Prompt or [Enter] to accept the default ($DefaultValue)"
    if (!$Value -eq "") {$ReadResult = $Value}
	return $ReadResult
}
# Get input values
$SourceDirectory = Read-Host-Default "Please enter the source directory" $SourceDirectory
$FileFilter = Read-Host-Default "Please enter the file filter" $FileFilter
$SourceEncodingName = Read-Host-Default "Please enter the source encoding name" $SourceEncodingName
$TargetEncodingName = Read-Host-Default "Please enter the target encoding name" $TargetEncodingName
$TargetEncodingCode = Read-Host-Default "Please enter the target encoding code" $TargetEncodingCode
[String]$Confirmation = Read-Host-Default ("Please enter the confirmation to change an encoding of all " + 
	$FileFilter + " files from " + $SourceEncodingName + " to " + $TargetEncodingName + 
	" of " + $SourceDirectory + " directory including subdirectories") "Y"
if (!$Confirmation -eq "" -And $Confirmation.ToUpper() -eq "Y") {
	try {
		# Get encodings
		$SourceEncoding = [System.Text.Encoding]::GetEncoding($SourceEncodingName)
		$TargetEncoding = [System.Text.Encoding]::GetEncoding($TargetEncodingName)
		# Get a list of the source files
		$FileCount = Get-ChildItem -Path $SourceDirectory -Recurse -File -Filter $FileFilter | Measure-Object | %{$_.Count}
		$FileList = Get-ChildItem -Path $SourceDirectory -Recurse -File -Filter $FileFilter
		$PercentComplete = 0
		$FileIndex = 0
		ForEach($File in $FileList) {
			$FileIndex += 1
			$PercentComplete = [math]::Round(($FileIndex / $FileCount) * 100)
			Write-Progress -Activity "Changing of files encoding in progress" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
			try {
				$Bytes = Get-Content -Path $File.FullName -Encoding Byte -ReadCount 0
				$Content = [System.Text.Encoding]::Convert($SourceEncoding, $TargetEncoding, $Bytes)
				Set-Content -Path $File.FullName $TargetEncoding.getString($Content) -Encoding $TargetEncodingCode
			} catch {
				Write-Error -Message ("Error occured during processing of " + $File.FullName + " file, Error: " + $_.Exception.Message) 
					-Category ParserError -ErrorId "E-001"
			}
		}
	} catch [System.IO.IOException] {
		Write-Error -Message ("Directory " + $SrcDir + " does not exist") -Category InvalidArgument -ErrorId "F-002"
	} catch {
		Write-Error -Message $_.Exception.Message -Category InvalidArgument -ErrorId "F-001"
	}
}
Read-Host "Done. Press [Enter] to continue"