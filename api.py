import secrets
import json
import random
import os
from flask import Flask, request, flash, redirect, url_for, render_template, session
from flask_pymongo import PyMongo
from twilio.rest import Client
from wtforms import Form, BooleanField, StringField, PasswordField, validators

app = Flask(__name__, template_folder='templates')
app.config["DEBUG"] = True

app.secret_key = "jakis klucz"
app.config['MONG_DBNAME'] = 'open_auth_engine_db'
app.config['MONGO_URI'] = os.environ["MONGODB_CONNECTION_STRING"]

mongo = PyMongo(app)

TWILLIO_ACCOUNT_SID = os.environ["TWILLIO_ACCOUNT_SID"]
TWILLIO_AUTCH_TOKEN = os.environ["TWILLIO_AUTCH_TOKEN"]


class RegistrationForm(Form):
    name = StringField('', [validators.Length(min=2, max=50), validators.DataRequired()], render_kw={"placeholder": "App name"})
    email = StringField('', [validators.Length(min=6, max=35), validators.DataRequired()],render_kw={"placeholder": "Email"})
    password = PasswordField('', [
        validators.DataRequired(),
        validators.EqualTo('confirm', message='Passwords must match')
    ], render_kw={"placeholder": "Password"})
    confirm = PasswordField('', render_kw={"placeholder": "Repeat Password"})
    accept = BooleanField('I accept policy', [validators.DataRequired()])


class LoginForm(Form):
    email = StringField('', [validators.Length(min=6, max=35)], render_kw={"placeholder": "Email"})
    password = PasswordField('', [
        validators.DataRequired()
    ], render_kw={"placeholder": "Password"})


class DeleteForm(Form):
    accept = BooleanField('I confirm that I want to delete the account', [validators.DataRequired()])


@app.route('/', methods=['GET', 'POST'])
def index():
    form = RegistrationForm(request.form)
    form2 = LoginForm(request.form)
    return render_template('register.html', form=form, form2=form2)


@app.route('/register', methods=['POST'])
def register():
    form = RegistrationForm(request.form)
    if request.method == 'POST' and form.validate():
        client_name = form.name.data
        client_email = form.email.data
        client_password = form.password.data
        client_auth_token = secrets.token_hex(24)

        # check if email and name already exists
        result = mongo.db.clients.find_one(
            {
                'client_email': str(client_email),
                'client_name': str(client_name)
            }
        )
        form2 = LoginForm(request.form)
        if result is not None:
            return render_template('register.html', form=form, form2=form2, message="Account already exists.")

        # insert new client
        client = {
            'client_name': str(client_name),
            'client_email': str(client_email),
            'client_password': str(client_password),
            'client_auth_token': client_auth_token
        }
        mongo.db.clients.insert_one(client)

        return render_template('register.html', form=form, form2=form2, message="Thanks for registering. Login to manage your app.")
    else:
        form2 = LoginForm(request.form)
        return render_template('register.html', form=form, form2=form2, error="Form error")


@app.route('/login', methods=['POST'])
def login():
    form = LoginForm(request.form)
    if request.method == 'POST' and form.validate():
        client_email = form.email.data
        client_password = form.password.data

        # check login and password and return user data
        response = mongo.db.clients.find_one(
            {
                'client_email': client_email,
                'client_password': client_password
            },
            {
                '_id': 0,
                'client_password': 0
            }
        )
        if response is None:
            form2 = RegistrationForm(request.form)
            return render_template('register.html', form=form2, form2=form, error="Wrong email or password.")
        return render_template('info.html', client_name=response['client_name'], client_email=response['client_email'], client_token=response['client_auth_token'])
    else:
        form2 = RegistrationForm(request.form)
        return render_template('register.html', form=form2, form2=form, error="Form error")


@app.route('/delete/<name>', methods=['GET', 'POST'])
def delete(name):
    deleteForm = DeleteForm(request.form)
    if request.method == 'POST' and deleteForm.validate():
        # TODO usuń konto z bazy (parametr name = nazwa apki)
        mongo.db.clients.delete_one(
            {
                'client_name': name
            }
        )
        form = RegistrationForm(request.form)
        form2 = LoginForm(request.form)
        return render_template('register.html', form=form, form2=form2, message='Account deleted')
    elif request.method == 'GET':
        return render_template('delete.html', form=deleteForm)
    else:
        form = RegistrationForm(request.form)
        form2 = LoginForm(request.form)
        return render_template('register.html', form=form, form2=form2, error="Form error")


"""
@app.route('/api/register', methods=['GET', 'POST', 'DELETE'])
def client_registration():
    js = request.json
    print(js)
    auth_token = secrets.token_hex(24)
    registered_clients.append({'client_name': js['client_name'], 'client_data': js['client_data'], 'auth_token': auth_token})
    return json.dumps({'auth_token': auth_token}), 200
"""


@app.route('/api/send_sms', methods=['POST'])
def client_login():
    js = request.json

    response = mongo.db.clients.find_one(
        {
            'auth_token': js['auth_token']
        },
        {
            'client_name': 1
        }
    )
    if response is None:
        return 'UNAUTHORIZED', 400

    client_name = response['client_name']

    """client_name = None
    for record in registered_clients:
        if record['auth_token'] == js['auth_token']:
            client_name = record['client_name']
    if client_name is None:
        return 'UNAUTHORIZED', 400"""

    client = Client(TWILLIO_ACCOUNT_SID, TWILLIO_AUTCH_TOKEN)
    """user_verification_code = ''.join(str(random.randint(0, 9)) for _ in range(6))
    user_verification.append({'user_number': js['user_number'], 'user_verification_code': user_verification_code})"""

    user_verification_code = secrets.token_hex(6)
    mongo.db.user_verification.insert_one({{'user_number': js['user_number'], 'user_verification_code': str(user_verification_code)}})

    message = client.messages.create(
        to="+48" + js['user_number'],
        from_="+19379155858",
        body="Twój numer weryfikacyjny w serwisie " + client_name + ": " + str(user_verification_code))

    return 'SMS SENT', 200


@app.route('/api/verify_sms', methods=['POST'])
def verify():
    js = request.json

    """client_name = None
    for record in registered_clients:
        if record['auth_token'] == js['auth_token']:
            client_name = record['client_name']
    if client_name is None:
        return 'UNAUTHORIZED', 400"""

    result = mongo.db.clients.find_one(
        {
            'auth_token': js['auth_token']
        },
        {
            '_id': 1
        }
    )
    if result is None:
        return 'UNAUTHORIZED', 400

    response = mongo.db.user_verification.find_one(
        {
            'user_verification_code': js['user_verification_code'],
            'user_number': js['user_number']
        },
        {
            '_id': 1
        }
    )
    if response is not None:
        mongo.db.user_verification.delete_one({'_id': response['_id']})
        return 'VERIFIED SUCCESSFULLY', 200

    """for record in user_verification:
        if record['user_verification_code'] == js['user_verification_code']:
            user_verification.remove(record)
            return 'VERIFIED SUCCESSFULLY', 200"""
    return 'WRONG CODE', 400


if __name__ == '__main__':
    app.run()
