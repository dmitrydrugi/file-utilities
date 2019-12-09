Write-Host "Hello, world"
$Win1251Encoding = [System.Text.Encoding]::GetEncoding("windows-1251")
$Utf8Encoding = [System.Text.Encoding]::GetEncoding("utf-8")
# Get a list of the source files
$FileList = Get-ChildItem -Path C:\temp -Recurse -File -Filter *.txt
ForEach($File in $FileList) {
	$Bytes = Get-Content -Path $File.FullName -Encoding Byte -ReadCount 0
	$Content = [System.Text.Encoding]::Convert($Win1251Encoding, $Utf8Encoding, $Bytes)
	Set-Content -Path $File.FullName $Utf8Encoding.getString($Content) -Encoding UTF8
}
Read-Host "Press Enter to continue"