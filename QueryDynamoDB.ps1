Import-Module -Name Pode -MaximumVersion 2.99.99
Import-Module -Name Pode.Web -MaximumVersion 2.99.99
Import-Module AWS.Tools.DynamoDBv2


$dynamoDBTable = 'DBA-EC2StateMonitor'

$invokeDDBQuery = @{
    TableName = $dynamoDBTable
    ProjectionExpression = "EventTime,EC2Instance,#state,#StartupType,#TagState"
    KeyConditionExpression = ' PK = :PK and begins_with(SK, :SK)'
    ExpressionAttributeNames = @{
        
        "#StartupType"  = "StartupType"
        "#state"        = "State"
        "#TagState"        = "TagState"
    }
    ExpressionAttributeValues = @{
        ':PK' = "$(Get-Date -format yyyy-MM-dd)"
        ':SK' = 'VRUK-A-ILTSQL03#RUNNING'
    } | ConvertTo-DDBItem
}
# Invoke-DDBQuery @invokeDDBQuery | ConvertFrom-DDBItem
$Results = Invoke-DDBQuery @invokeDDBQuery | ConvertFrom-DDBItem
$Results[0]
$ResObj = @()
$Results | ForEach-Object {

    $Res = [PSCustomObject]@{

        EC2Instance = $Results['EC2Instance']
        EventTime   = $Results['EventTime']
        State       = $Results['State']
        StartupType = $Results['StartupType']
        TagState    = $Results['TagState']
        
    }
    $ResObj += $Res
}
$ResObj | ft
