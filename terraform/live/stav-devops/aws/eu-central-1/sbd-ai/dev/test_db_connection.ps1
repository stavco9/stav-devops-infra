$awsProfile = "stav-devops"

$checkCredentials = aws sts get-caller-identity --profile $awsProfile 2>$null | ConvertFrom-Json

if ($?) {
  if ($checkCredentials.Arn -like "*AWSReservedSSO*") {
      $tempCredentials = aws configure export-credentials --profile $awsProfile | ConvertFrom-Json
      $accessKeyId = $tempCredentials.AccessKeyId
      $secretAccessKey = $tempCredentials.SecretAccessKey
      $sessionToken = $tempCredentials.SessionToken
  } else {
      $tempCredentials = aws sts get-session-token --profile $awsProfile --format json 2>$null | ConvertFrom-Json
      $accessKeyId = $tempCredentials.Credentials.AccessKeyId
      $secretAccessKey = $tempCredentials.Credentials.SecretAccessKey
      $sessionToken = $tempCredentials.Credentials.SessionToken
  }

  mongosh "mongodb+srv://sbdai-mongodb-dev.w323dzy.mongodb.net/?authSource=%24external&authMechanism=MONGODB-AWS" `
    --apiVersion 1 --username $accessKeyId --password $secretAccessKey --awsIamSessionToken $sessionToken
}
else{
  Write-Host "Error: $checkCredentials. Please check your AWS credentials and try again."
}