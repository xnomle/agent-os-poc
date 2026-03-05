import os
import pytest
import httpx


API_BASE_URL = os.environ.get("API_BASE_URL", "")


@pytest.mark.skipif(not API_BASE_URL, reason="API_BASE_URL not set")
def test_api_returns_200():
    response = httpx.post(API_BASE_URL, timeout=10)
    assert response.status_code == 200


@pytest.mark.skipif(not API_BASE_URL, reason="API_BASE_URL not set")
def test_api_returns_hello_world():
    response = httpx.post(API_BASE_URL, timeout=10)
    assert "Hello World" in response.text
