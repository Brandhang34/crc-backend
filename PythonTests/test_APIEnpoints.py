import requests



def test_call_user_counter_endpoint():
    USER_COUNTER_ENDPOINT="https://5lvhykrezk.execute-api.us-east-1.amazonaws.com/Prod/trigger"
    response = requests.get(USER_COUNTER_ENDPOINT)
    assert response.status_code == 200

def test_call_contact_form_endpoint():
    CONTACT_FORM_ENDPOINT="https://5lvhykrezk.execute-api.us-east-1.amazonaws.com/Prod/ses_contact_me"
    payload = {
            "name": "test_name",
            "subject": "test_subject",
            "email": "test_email@example.com",
            "message": "test_message",
            }
    response = requests.post(CONTACT_FORM_ENDPOINT,json=payload)
    assert response.status_code == 200
