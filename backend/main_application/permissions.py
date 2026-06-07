from rest_framework import permissions
from .models import Voter


class IsVoter(permissions.BasePermission):
    def has_permission(self, request, view):
        return isinstance(request.user, Voter)
