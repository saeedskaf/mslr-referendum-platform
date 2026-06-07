from rest_framework import status, generics
from rest_framework.decorators import (
    api_view,
    permission_classes,
    authentication_classes,
)
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import Voter, Referendum, ReferendumOption, Vote, ElectionCommission, SCC
from .serializers import (
    VoterRegistrationSerializer,
    VoterLoginSerializer,
    ECLoginSerializer,
    ReferendumSerializer,
    VoteSerializer,
    ReferendumAPISerializer,
    ReferendumVoterSerializer,
)
from .permissions import IsVoter


def get_tokens_for_voter(voter):
    # generate access + refresh tokens for the voter
    refresh = RefreshToken.for_user(voter)
    return {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
    }


@swagger_auto_schema(
    method="post",
    request_body=VoterRegistrationSerializer,
    responses={
        201: openapi.Response(
            description="Registration successful",
            examples={
                "application/json": {
                    "message": "Registration successful",
                    "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                    "voter": {"email": "voter@example.com", "full_name": "John Doe"},
                }
            },
        ),
        400: "Bad request - validation errors",
    },
)
@api_view(["POST"])
@permission_classes([AllowAny])
def voter_register(request):
    # new voter signup
    serializer = VoterRegistrationSerializer(data=request.data)
    if serializer.is_valid():
        voter = serializer.save()
        tokens = get_tokens_for_voter(voter)
        return Response(
            {
                "message": "Registration successful",
                "access": tokens["access"],
                "refresh": tokens["refresh"],
                "voter": {"email": voter.email, "full_name": voter.full_name},
            },
            status=status.HTTP_201_CREATED,
        )
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method="post",
    request_body=VoterLoginSerializer,
    responses={
        200: openapi.Response(
            description="Login successful",
            examples={
                "application/json": {
                    "message": "Login successful",
                    "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
                    "voter": {"email": "voter@example.com", "full_name": "John Doe"},
                }
            },
        ),
        401: "Invalid credentials",
    },
)
@api_view(["POST"])
@permission_classes([AllowAny])
def voter_login(request):
    # voter login - check creds and return tokens
    serializer = VoterLoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data["email"]
        password = serializer.validated_data["password"]

        try:
            voter = Voter.objects.get(email=email)
            if voter.check_password(password):
                tokens = get_tokens_for_voter(voter)
                response = Response(
                    {
                        "message": "Login successful",
                        "access": tokens["access"],
                        "refresh": tokens["refresh"],
                        "voter": {"email": voter.email, "full_name": voter.full_name},
                    }
                )
                response.set_cookie(
                    "last_login_email", email, max_age=30 * 24 * 60 * 60
                )
                return response
        except Voter.DoesNotExist:
            pass

        return Response(
            {"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED
        )
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method="post",
    request_body=ECLoginSerializer,
    responses={
        200: openapi.Response(
            description="Login successful",
            examples={
                "application/json": {
                    "message": "Login successful",
                    "access": "accesssssssssssssssssssssssss",
                    "refresh": "refreshhhhhhhhhhhhhh",
                    "session_token": "ec_session_token_here",
                }
            },
        ),
        401: "Invalid credentials",
    },
)
@api_view(["POST"])
@permission_classes([AllowAny])
def ec_login(request):
    # election commission login - hardcoded creds for now
    serializer = ECLoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data["email"]
        password = serializer.validated_data["password"]

        if email == "ec@referendum.gov.sr" and password == "Shangrilavote&2025@":
            return Response(
                {
                    "message": "Login successful",
                    "access": "EC_SECRET_TOKEN_2025",
                    "email": email,
                    "role": "election_commission",
                }
            )

        return Response(
            {"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED
        )
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(method="post", responses={200: "Logout successful"})
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def voter_logout(request):
    return Response({"message": "Logout successful. Please discard your tokens."})


@swagger_auto_schema(
    method="get",
    responses={200: ReferendumSerializer(many=True)},
    security=[{"Bearer": []}],
)
@api_view(["GET"])
@permission_classes([IsAuthenticated, IsVoter])
def voter_referendums(request):
    # get all referendums for voter dashboard
    referendums = Referendum.objects.all().prefetch_related("options")
    serializer = ReferendumVoterSerializer(
        referendums, context={"request": request}, many=True
    )
    return Response(serializer.data)


@swagger_auto_schema(
    method="post",
    request_body=VoteSerializer,
    responses={201: "Vote cast successfully", 400: "Bad request - validation errors"},
    security=[{"Bearer": []}],
)
@api_view(["POST"])
@permission_classes([IsAuthenticated, IsVoter])
def cast_vote(request):
    # submit a vote
    serializer = VoteSerializer(data=request.data, context={"request": request})
    if serializer.is_valid():
        serializer.save()
        return Response(
            {"message": "Vote cast successfully"}, status=status.HTTP_201_CREATED
        )
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method="get",
    responses={
        200: openapi.Response(
            description="Vote status",
            examples={"application/json": {"has_voted": True}},
        )
    },
    security=[{"Bearer": []}],
)
@api_view(["GET"])
@permission_classes([IsAuthenticated, IsVoter])
def check_vote_status(request, referendum_id):
    # check if this voter already voted on a referendum
    has_voted = Vote.objects.filter(
        voter=request.user, referendum_id=referendum_id
    ).exists()
    return Response({"has_voted": has_voted})


def verify_ec_token(request):
    auth_header = request.META.get("HTTP_AUTHORIZATION", "")
    if not auth_header.startswith("Bearer "):
        return False
    token = auth_header.split(" ")[1]
    return token == "EC_SECRET_TOKEN_2025"


@swagger_auto_schema(method="get", responses={200: ReferendumSerializer(many=True)})
@api_view(["GET"])
@authentication_classes([])
@permission_classes([AllowAny])
def ec_list_referendums(request):
    # EC: list all referendums
    auth_header = request.META.get("HTTP_AUTHORIZATION", "")
    if not auth_header.startswith("Bearer "):
        return Response(
            {"error": "Authentication required"}, status=status.HTTP_401_UNAUTHORIZED
        )

    token = auth_header.split(" ")[1]
    if token != "EC_SECRET_TOKEN_2025":
        return Response({"error": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)
    referendums = Referendum.objects.all().prefetch_related("options")
    serializer = ReferendumSerializer(referendums, many=True)
    return Response(serializer.data)


@swagger_auto_schema(
    method="post",
    request_body=ReferendumSerializer,
    responses={201: "Referendum created", 400: "Bad request"},
)
@api_view(["POST"])
@authentication_classes([])
@permission_classes([AllowAny])
def ec_create_referendum(request):
    # EC: create new referendum
    auth_header = request.META.get("HTTP_AUTHORIZATION", "")
    if not auth_header.startswith("Bearer "):
        return Response(
            {"error": "Authentication required"}, status=status.HTTP_401_UNAUTHORIZED
        )

    token = auth_header.split(" ")[1]
    if token != "EC_SECRET_TOKEN_2025":
        return Response({"error": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)
    serializer = ReferendumSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method="put",
    request_body=ReferendumSerializer,
    responses={
        200: "Referendum updated",
        400: "Bad request",
        404: "Referendum not found",
    },
)
@api_view(["PUT", "PATCH"])
@authentication_classes([])
@permission_classes([AllowAny])
def ec_update_referendum(request, pk):
    # EC: update existing referendum
    auth_header = request.META.get("HTTP_AUTHORIZATION", "")
    if not auth_header.startswith("Bearer "):
        return Response(
            {"error": "Authentication required"}, status=status.HTTP_401_UNAUTHORIZED
        )

    token = auth_header.split(" ")[1]
    if token != "EC_SECRET_TOKEN_2025":
        return Response({"error": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)
    try:
        referendum = Referendum.objects.get(pk=pk)
    except Referendum.DoesNotExist:
        return Response(
            {"error": "Referendum not found"}, status=status.HTTP_404_NOT_FOUND
        )

    serializer = ReferendumSerializer(referendum, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method="get", responses={200: ReferendumSerializer(), 404: "Referendum not found"}
)
@api_view(["GET"])
@authentication_classes([])
@permission_classes([AllowAny])
def ec_referendum_detail(request, pk):
    # EC: get single referendum details
    auth_header = request.META.get("HTTP_AUTHORIZATION", "")
    if not auth_header.startswith("Bearer "):
        return Response(
            {"error": "Authentication required"}, status=status.HTTP_401_UNAUTHORIZED
        )

    token = auth_header.split(" ")[1]
    if token != "EC_SECRET_TOKEN_2025":
        return Response({"error": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)
    try:
        referendum = Referendum.objects.get(pk=pk)
        serializer = ReferendumSerializer(referendum)
        return Response(serializer.data)
    except Referendum.DoesNotExist:
        return Response(
            {"error": "Referendum not found"}, status=status.HTTP_404_NOT_FOUND
        )


@swagger_auto_schema(
    method="get",
    manual_parameters=[
        openapi.Parameter(
            "status",
            openapi.IN_QUERY,
            description="Filter by status (open/closed)",
            type=openapi.TYPE_STRING,
            enum=["open", "closed"],
        )
    ],
    responses={
        200: openapi.Response(
            description="List of referendums",
            examples={
                "application/json": {
                    "Referendums": [
                        {
                            "referendum_id": "1",
                            "status": "open",
                            "referendum_title": "Sample Title",
                            "referendum_desc": "Sample Description",
                            "referendum_options": {
                                "options": [
                                    {"1": "Option 1", "votes": "15"},
                                    {"2": "Option 2", "votes": "30"},
                                ]
                            },
                        }
                    ]
                }
            },
        )
    },
)
@api_view(["GET"])
@permission_classes([AllowAny])
def api_referendums_by_status(request):
    # public api - get referendums
    status_filter = request.query_params.get("status", None)

    if status_filter:
        referendums = Referendum.objects.filter(status=status_filter).prefetch_related(
            "options"
        )
    else:
        referendums = Referendum.objects.all().prefetch_related("options")

    serializer = ReferendumAPISerializer(referendums, many=True)
    return Response({"Referendums": serializer.data})


@swagger_auto_schema(
    method="get",
    responses={
        200: openapi.Response(
            description="Referendum details",
            examples={
                "application/json": {
                    "referendum_id": "1",
                    "status": "open",
                    "referendum_title": "Sample Title",
                    "referendum_desc": "Sample Description",
                    "referendum_options": {
                        "options": [
                            {"1": "Option 1", "votes": "15"},
                            {"2": "Option 2", "votes": "30"},
                        ]
                    },
                }
            },
        ),
        404: "Referendum not found",
    },
)
@api_view(["GET"])
@permission_classes([AllowAny])
def api_referendum_by_id(request, referendum_id):
    # public api - get single referendum by id
    try:
        referendum = Referendum.objects.prefetch_related("options").get(
            pk=referendum_id
        )
        serializer = ReferendumAPISerializer(referendum)
        return Response(serializer.data)
    except Referendum.DoesNotExist:
        return Response(
            {"error": "Referendum not found"}, status=status.HTTP_404_NOT_FOUND
        )