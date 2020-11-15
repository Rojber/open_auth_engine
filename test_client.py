import time
import requests


def print_request(request):
    print('------------------------------------')
    print('request.url:', request.url)
    print('request.status_code:', request.status_code)
    print('request.headers:', request.headers)
    print('request.text', request.text)
    if request.request.body is not None:
        print('request.request.body:', request.request.body)
    print('request.request.headers:', request.request.headers)
    print('------------------------------------')


if __name__ == '__main__':
    # numer musi byc zweryfikowany w Twidio!
    user_number = ""
    user_verification_code = ""

    request = requests.post('http://127.0.0.1:5000/api/register', json={'client_name': 'TEST', 'client_data': {}})
    print_request(request)
    js = request.json()
    time.sleep(0.01)

    request = requests.post('http://127.0.0.1:5000/api/send_sms', json={'auth_token': js['auth_token'], 'user_number': user_number})
    print_request(request)
    time.sleep(0.01)

    request = requests.post('http://127.0.0.1:5000/api/verify_sms', json={'auth_token': js['auth_token'], 'user_verification_code': user_verification_code})
    print_request(request)
    time.sleep(0.01)
