import os
import json
import boto3


def lambda_handler(event, context):
    ses = boto3.client(
        "ses", region_name="us-east-1"
    )  # Replace 'your-aws-region' with your actual AWS region

    destination = {"ToAddresses": [os.environ["TO_EMAIL_ADDRESS"]]}

    message = {
        "Body": {
            "Text": {
                "Data": f"name: {event['name']}\nemail: {event['email']}\nmessage: {event['message']}"
            }
        },
        "Subject": {"Data": event["subject"]},
    }

    source = os.environ["SOURCE_EMAIL_ADDRESS"]

    try:
        response = ses.send_email(
            Destination=destination, Message=message, Source=source
        )
        print("Email sent. MessageId:", response["MessageId"])

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Email sent successfully"}),
        }
    except Exception as e:
        print("Error sending email:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error sending email"}),
        }
