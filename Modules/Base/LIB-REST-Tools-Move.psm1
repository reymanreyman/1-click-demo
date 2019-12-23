

Function REST-Move-Login {
  Param (
    [object] $datagen,
    [object] $datavar,
    [string] $mode = "First"
  )

  $credPair = "nutanix:nutanix/4u"
  $encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
  $headers = @{ Authorization = "Basic $encodedCredentials" }

  write-log -message "Replacing JSON String Variables"
$Json = @"
{
    "username":"nutanix",
    "password":"nutanix/4u"
}
"@ 

  if ($mode -ne "First"){
    write-log -message "using second pass $($datavar.PEPass)"
    
$Json = @"
{
    "username":"nutanix",
    "password":"$($datavar.PEPass)"
}
"@ 
    if ($debug -ge 2 ){
      $json | out-file c:\temp\movelogin.json
    } 
  }
  $URL = "https://$($datagen.MoveIP)/v1/users/login"

  write-log -message "Using URL $URL"

  try{
    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  } catch {
    sleep 10

    $FName = Get-FunctionName;write-log -message "Error Caught on function $FName" -sev "WARN"

    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  }

  Return $task
} 

Function REST-Move-EULA {
  Param (
    [object] $Token,
    [object] $datagen,
    [object] $datavar
  )

  $headers = @{ Authorization = $token.token }

  write-log -message "Replacing JSON String Variables"
$Json = @"
{
  "EulaAccepted":true,
  "TelemetryOn":true,
  "NewPassword":"$($datavar.PEPass)"
}
"@ 
  $URL = "https://$($datagen.MoveIP)/v1/configure"

  write-log -message "Using URL $URL"

  try{
    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  } catch {
    sleep 10

    $FName = Get-FunctionName;write-log -message "Error Caught on function $FName" -sev "WARN"

    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  }

  Return $task
} 

Function REST-Move-SetProvider {
  Param (
    [object] $Token,
    [object] $datagen,
    [object] $datavar
  )

  $headers = @{ Authorization = $token.token }

  write-log -message "Replacing JSON String Variables"
$Json = @"
{
  "Spec": {
    "Name": "poc",
    "AhvAccessInfo": {
      "IPorFQDN": "$($datavar.PEClusterIP)",
      "Username": "$($datagen.MoveAPIAccount)",
      "Password": "$($datavar.pepass)"
    },
    "Type": "AHV",
    "Role": 2
  }
}
"@ 
  $URL = "https://$($datagen.MoveIP)/move/v2/providers"
  if ($debug -ge 2){
    $json | out-file c:\temp\move2.json
  }
  write-log -message "Using URL $URL"

  try{
    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  } catch {
    sleep 10

    $FName = Get-FunctionName;write-log -message "Error Caught on function $FName" -sev "WARN"

    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  }

  Return $task
} 

Function REST-Move-GetProvider {
  Param (
    [object] $Token,
    [object] $datagen,
    [object] $datavar
  )

  $headers = @{ Authorization = $token.token }

  $URL = "https://$($datagen.MoveIP)/move/v2/providers/list"

  write-log -message "Getting Move Targets"
  write-log -message "Using URL $URL"
$Json = @"
{
  "Role": 2
}
"@ 


  write-log -message "Using URL $URL"

  try{
    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  } catch {
    sleep 10

    $FName = Get-FunctionName;write-log -message "Error Caught on function $FName" -sev "WARN"

    $task = Invoke-RestMethod -Uri $URL -method "post" -body $Json -ContentType 'application/json' -headers $headers;
  }

  Return $task
} 
