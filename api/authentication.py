from django.conf import settings
from rest_framework import authentication, exceptions


class ApiKeyUser:
    """Lightweight synthetic user representing an authenticated API-key caller.

    Avoids a DB write per request and decouples key-auth from the user table.
    Has just enough of the Django user contract for DRF permission checks.
    """

    is_authenticated = True
    is_anonymous = False
    is_active = True
    is_staff = False
    is_superuser = False
    pk = None
    id = None
    username = 'api_guest'

    def __str__(self):
        return self.username

    def has_perm(self, perm, obj=None):
        return False

    def has_perms(self, perm_list, obj=None):
        return False

    def has_module_perms(self, module):
        return False


class ApiKeyAuthentication(authentication.BaseAuthentication):
    keyword = 'ApiKey'

    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith(f'{self.keyword} '):
            return None

        provided = auth_header[len(self.keyword) + 1:].strip()
        expected = (settings.API_KEY or '').strip()

        if not expected or not provided or provided != expected:
            raise exceptions.AuthenticationFailed('Invalid API Key')

        return (ApiKeyUser(), None)

    def authenticate_header(self, request):
        return self.keyword
