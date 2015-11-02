# django-production
Dockerfile that creates a Django (Python 2.7.x) production environment on Ubuntu Trusty, running on uWSGI and nginx.

# Usage

To deploy your Django app, copy the project into a directory and ensure it has a structure similar to that shown below. In the root of the new directory, copy your pip requirements into "requirements.txt". In the same directory, you will then need to create a "start.sh" file with the parameters of your project defined (see example below directory structure).

```
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
│   ├── ExampleApp
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
```

# start.sh

```bash
#!/bin/bash

django-nginx-setup --working-directory example-project --static-directory static --static-alias /static --wsgi-module example_app.wsgi
```

# To run the container, use the below command structure (requires mounting the directory you created to the container at /app):

```bash
docker run -d -p 8125:80 -v /path/to/your/directory:/app davidj/django-production
```

You can now go to http://localhost:8125 to see your site.

# Troubleshooting

You may need to add the path to your project at run-time, by editing wsgi.py and adding in these lines:

```python
import sys

path = '/app/example-project/'

if path not in sys.path:
    sys.path.append(path)
```

If you are not using a domain, in your settings.py file you can use this ALLOWED_HOSTS block:

```python
ALLOWED_HOSTS = [
    '127.0.0.1',
    'localhost'
]
```
