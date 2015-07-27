# settings from settings.py

# generate a secret key https://www.grc.com/passwords.htm
secret_key = ''

databases = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': 'ukrop.db',
        'USER': '',
        'PASSWORD': '',
        'HOST': '',
        'PORT': '',
    },
}

projectFolder = 'envFolder'

# from ukroppen/sendmail.py
alertsEmailPwd = ''
# from dupechecker/dupechecker.py
proxyPwd = ''
# from dupechecker/views.py
liqpayPublicKey = ""
liqpayPrivateKey = ""

