import requests

ENDPOINT="https://5lvhykrezk.execute-api.us-east-1.amazonaws.com/Prod/trigger"

def test_call_endpoint():
    response = requests.get(ENDPOINT)
    assert response.status_code == 200
