import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'src'))

from handler import lambda_handler


def test_handler_returns_200():
    result = lambda_handler({}, {})
    assert result["statusCode"] == 200


def test_handler_returns_hello_world():
    result = lambda_handler({}, {})
    assert result["body"] == '"Hello World"'
