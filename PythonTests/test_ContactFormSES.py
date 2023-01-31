import requests

ENDPOINT="https://5lvhykrezk.execute-api.us-east-1.amazonaws.com/Prod/ses_contact_me"

def test_post():
    payload = {
            "name": "test_name",
            "subject": "test_subject",
            "email": "test_email@example.com",
            "message": "test_message",
            }
    response = requests.post(ENDPOINT,json=payload)
    assert response.status_code == 200
