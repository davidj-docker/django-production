# django-production
Dockerfile that creates a Django (Python 2.7.x) production environment on Ubuntu Trusty, running on uWSGI and nginx.

# Usage

.
├── example-project
│   ├── example_app
│   │   ├── __init__.py
│   │   ├── __init__.pyc
│   │   ├── settings.py
│   │   ├── settings.pyc
│   │   ├── urls.py
│   │   ├── urls.pyc
│   │   ├── wsgi.py
│   │   └── wsgi.pyc
│   ├── manage.py
│   ├── Example App
│   │   ├── admin.py
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── tests.py
│   │   └── views
│   │       ├── __init__.py
│   │       ├── ExampleView.py
│   ├── static
│   │   └── favicon.ico
│   └── templates
│       └── base.html
├── requirements.txt
└── start.sh
