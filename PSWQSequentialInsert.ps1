
param (
    [string]$item,
    [int]$count
)



#############################################
#To understand setting parameters, see below:#
#############################################



$TenantId = 'XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'    
    #The Directory (tenant) ID of the App registration 
$AppId = 'XXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX'   
    #The Application (client) ID of the App registration 
$ClientSecret = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'   
    #The client secret generated within the App registration 
$PowerPlatformOrg = 'orgXXXXXXX'    
    #Dynamics 365 Organization ID / YourEnvironmentId
$PowerPlatformEnvironmentUrl = "https://$($PowerPlatformOrg).crm.dynamics.com" 
    #The URL of the Dataverse environment you want to connect to perform CRUD Operation
$oAuthTokenEndpoint = "https://login.microsoftonline.com/$($TenantId)/oauth2/v2.0/token" 
    <# The “v2 OAuth” endpoint is for the App registration. You’ll want to open the app registration and click the “endpoints” button 
       in the overview area to find it. Then, copy the “OAuth 2.0” token endpoint (v2) URL. #>





#############################################
#To generate the access token, see below:###  
#############################################



# OAuth Body Access Token Request
$authBody = @{
    client_id = $AppId;
    client_secret = $ClientSecret;    
    # The v2 endpoint for OAuth uses scope instead of resource
    scope = "$($PowerPlatformEnvironmentUrl)/.default"    
    grant_type = 'client_credentials'
}
# Parameters for OAuth Access Token Request
$authParams = @{
    URI = $oAuthTokenEndpoint
    Method = 'POST'
    ContentType = 'application/x-www-form-urlencoded'
    Body = $authBody
}
# Get Access Token
$authResponseObject = Invoke-RestMethod @authParams -ErrorAction Stop
# Output
$authResponseObject


###################################################
#To insert a record in the work queue item table, see below:#
###################################################




# Define the table you want to insert a record into
$entitySetName = "workqueueitems"

# Set the "workqueueid" to a valid reference
$workqueueid = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXX'  # Replace with a valid "workqueueid" value

# Construct the URI for creating a new record
$postRequestUri = "$entitySetName"

# Create a JSON payload for the new record with the correctly formatted "workqueueid" reference
$postBody = @{
    'input' = "$item,$count"
    'workqueueid@odata.bind' = "/workqueues($workqueueid)"  # Replace "workqueues" with the actual entity set name for workqueues
    # Add other fields as needed
} | ConvertTo-Json

# Set up web API call parameters, including a header for the access token
$postApiCallParams = @{
    URI = "$($PowerPlatformEnvironmentUrl)/api/data/v9.1/$($postRequestUri)"
    Headers = @{
        "Authorization" = "$($authResponseObject.token_type) $($authResponseObject.access_token)"
        "Accept" = "application/json"
        "OData-MaxVersion" = "4.0"
        "OData-Version" = "4.0"
        "Content-Type" = "application/json; charset=utf-8"
        "Prefer" = "return=representation"  # in order to return data
    }
    Method = 'POST'
    Body = $postBody
}

# Call the API to create a new record
$postApiResponseObject = Invoke-RestMethod @postApiCallParams -ErrorAction Stop

# Output the response
$postApiResponseObject
