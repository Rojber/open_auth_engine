import secrets
import json
import random
from flask import Flask, request, flash, redirect, url_for, render_template, session
from twilio.rest import Client
from wtforms import Form, BooleanField, StringField, PasswordField, validators

app = Flask(__name__, template_folder='templates')
app.config["DEBUG"] = True

app.secret_key = "jakis klucz"

# Your Account SID from twilio.com/console
twilio_account_sid = "AC2d7906eb701a6f425a68afc9ad0713cc"
# Your Auth Token from twilio.com/console
twilio_auth_token = "c1d6735040fc608c036450b7fe2788da"

registered_clients = []
user_verification = []


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
        client_email = form.email
        client_password = form.password
        client_auth_token = secrets.token_hex(24)
        # TODO
        # insert data into db
        # check if app exists
        form2 = LoginForm(request.form)
        return render_template('register.html', form=form, form2=form2, message="Thanks for registering. Login to manage your app.")
    else:
        form2 = LoginForm(request.form)
        return render_template('register.html', form=form, form2=form2, error="Form error")


@app.route('/login', methods=['POST'])
def login():
    form = LoginForm(request.form)
    if request.method == 'POST' and form.validate():
        client_email = form.email
        client_password = form.password
        # TODO
        # check password
        # return user data from database
        return "zalogowany"
    else:
        flash('From error.')
        return redirect(url_for('index'))


@app.route('/api/register', methods=['GET', 'POST', 'DELETE'])
def client_registration():
    js = request.json
    print(js)
    auth_token = secrets.token_hex(24)
    registered_clients.append({'client_name': js['client_name'], 'client_data': js['client_data'], 'auth_token': auth_token})
    return json.dumps({'auth_token': auth_token}), 200


@app.route('/api/send_sms', methods=['POST'])
def client_login():
    js = request.json
    client_name = None
    for record in registered_clients:
        if record['auth_token'] == js['auth_token']:
            client_name = record['client_name']
    if client_name is None:
        return 'UNAUTHORIZED', 400

    client = Client(twilio_account_sid, twilio_auth_token)
    user_verification_code = ''.join(str(random.randint(0, 9)) for _ in range(6))
    user_verification.append({'user_number': js['user_number'], 'user_verification_code': user_verification_code})
    message = client.messages.create(
        to="+48" + js['user_number'],
        from_="+19379155858",
        body="Twój numer weryfikacyjny w serwisie " + client_name + ": " + str(user_verification_code))

    return 'SMS SENT', 200


@app.route('/api/verify_sms', methods=['POST'])
def verify():
    js = request.json
    client_name = None
    for record in registered_clients:
        if record['auth_token'] == js['auth_token']:
            client_name = record['client_name']
    if client_name is None:
        return 'UNAUTHORIZED', 400

    for record in user_verification:
        if record['user_verification_code'] == js['user_verification_code']:
            user_verification.remove(record)
            return 'VERIFIED SUCCESSFULLY', 200
    return 'WRONG CODE', 400


if __name__ == '__main__':
    app.run()
