[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$login = Invoke-RestMethod -Uri https://transkribus.eu/TrpServer/rest/auth/login -Body "user=&pw=" -Method Post -SessionVariable session

$response = Invoke-RestMethod -Uri https://transkribus.eu/TrpServer/rest/collections/448/list -Method Get -WebSession $session
$tr1 = $response | Where-Object { $_.docId -gt 19200 }

$all = [System.Collections.ArrayList]@()

$tr1 | % {
	$fileID = $_.docId
	$title = $_.title
	$datum = $title.substring(2, 4) + "-" + $title.substring(6,2) + "-" + $title.substring(8,2) 
	
	$req = "https://transkribus.eu/TrpServer/rest/collections/448/$fileID/fulldoc"
	$res = Invoke-RestMethod -Uri $req -Method Get -WebSession $session
	$res | % { $_.pageList.pages | % {
		
		$tss = $_.tsList.transcripts | Sort-Object -Property tsId -Descending
		$entry = @{"id" = $fileID; "titel" = $title; "datum" = $datum; "seite" = $_.pageNr; "status" = $tss[0].status; "regions" = $tss[0].nrOfRegions; "lines" = $tss[0].nrOfLines; "words" = $tss[0].nrOfWords}
		$all.Add($entry) 
	}}
}

$json = @{"data" = $all} | ConvertTo-Json |  Out-File -FilePath 'data.json'
