from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # Voter endpoints
    path("voter/register/", views.voter_register, name="voter-register"),
    path("voter/login/", views.voter_login, name="voter-login"),
    path("voter/logout/", views.voter_logout, name="voter-logout"),
    path("voter/token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("voter/referendums/", views.voter_referendums, name="voter-referendums"),
    path("voter/vote/", views.cast_vote, name="cast-vote"),
    path(
        "voter/vote-status/<int:referendum_id>/",
        views.check_vote_status,
        name="check-vote-status",
    ),
    # Election Commission endpoints
    path("ec/login/", views.ec_login, name="ec-login"),
    path("ec/referendums/", views.ec_list_referendums, name="ec-list-referendums"),
    path(
        "ec/referendums/create/",
        views.ec_create_referendum,
        name="ec-create-referendum",
    ),
    path(
        "ec/referendums/<int:pk>/",
        views.ec_referendum_detail,
        name="ec-referendum-detail",
    ),
    path(
        "ec/referendums/<int:pk>/update/",
        views.ec_update_referendum,
        name="ec-update-referendum",
    ),
    # REST API endpoints (public)
    path(
        "mslr/referendums",
        views.api_referendums_by_status,
        name="api-referendums-status",
    ),
    path(
        "mslr/referendum/<int:referendum_id>",
        views.api_referendum_by_id,
        name="api-referendum-id",
    ),
]
