Write-Host "Hi there!"
$SourceDirectory = "C:\temp"
$FileFilter = "*.txt"
$SourceEncodingName = "windows-1251"
$DestinationEncodingName = "utf-8"
$DestinationEncodingCode = "UTF8"
try {
	# Get encodings
	$SourceEncoding = [System.Text.Encoding]::GetEncoding($SourceEncodingName)
	$DestinationEncoding = [System.Text.Encoding]::GetEncoding($DestinatioEncodingName)
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
			$Content = [System.Text.Encoding]::Convert($SourceEncoding, $DestinationEncoding, $Bytes)
			Set-Content -Path $File.FullName $DestinationEncoding.getString($Content) -Encoding $DestinationEncodingCode
		} catch {
			Write-Error -Message ("Error occured during processing of " + $File.FullName + " file, Error: " + $_.Exception.Message) 
				-Category ParserError -ErrorId "E-003"
		}
	}
} catch [System.IO.IOException] {
	Write-Error -Message ("Directory " + $SrcDir + " does not exist") -Category InvalidArgument -ErrorId "E-002"
} catch {
	Write-Error -Message $_.Exception.Message -Category InvalidArgument -ErrorId "E-001"
}
Read-Host "Press Enter to continue"