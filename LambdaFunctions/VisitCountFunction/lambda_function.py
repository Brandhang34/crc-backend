import boto3
import os

def lambda_handler(event: any, context: any):
    user = "visitor"
    visit_count: int=0

    #Create a DynamoDB client
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["TABLE_NAME"]
    table = dynamodb.Table(table_name)

    #Get the current visit count
    response = table.get_item(TableName=table_name, Key={"id": user})
    if "Item" in response:
         visit_count = response["Item"]["count"]

    # Increment the visit count
    visit_count += 1

    # Put the new visit count into the DynamoDB table
    table.put_item(Item={"id": user, "count": visit_count})

    return {"message": visit_count}
