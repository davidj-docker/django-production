# django-production
Dockerfile that creates a Django (Python 2.7.x) production environment on Ubuntu Trusty, running on uWSGI and nginx, designed for deployment on an Apache Mesos/Marathon cluster.

# Example Usage

To deploy your Django app, copy the project into a directory and ensure it has a structure similar to that shown below. In the root of the new directory, copy your pip requirements into "requirements.txt". In the same directory, you will then need to create a "start.sh" file with the parameters of your project defined (see example below directory structure).

```
.
├── example-project
│   ├── example_app
│   │   ├── __init__.py
│   │   ├── settings.py
│   │   ├── urls.py
│   │   ├── wsgi.py
│   ├── manage.py
│   ├── ExampleApp
│   │   ├── admin.py
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── tests.py
│   │   └── views
│   │       ├── __init__.py
│   │       ├── ExampleView.py
│   │       └── Health.py
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

# Running the container

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
    '.ec2.internal',  # If you're using AWS
    '0.0.0.0',  # If you're using HAProxy health checks
    '127.0.0.1',
    'localhost'
]
```

In your urls.py file, if you're using a health check; Marathon will not follow the APPEND_SLASH redirect properly, so make sure your url pattern works with and without the slash:

```python
from ExampleApp.views import *
from django.views.decorators.csrf import csrf_exempt

urlpatterns = patterns(
    url(r'^health/?$', csrf_exempt(Health.as_view())),
)
```
