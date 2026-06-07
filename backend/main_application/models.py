from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from django.core.validators import RegexValidator
import hashlib


class VoterManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
      
        extra_fields.setdefault("is_active", True)

        return self.create_user(email, password, **extra_fields)


class SCC(models.Model):
    code = models.CharField(max_length=10, unique=True, primary_key=True)
    is_used = models.BooleanField(default=False)

    class Meta:
        db_table = "scc_codes"


class Voter(AbstractBaseUser):
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255)
    date_of_birth = models.DateField()
    scc = models.OneToOneField(SCC, on_delete=models.PROTECT, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    is_staff = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=True)

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return self.is_superuser

    objects = VoterManager()

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["full_name", "date_of_birth"]

    class Meta:
        db_table = "voters"


class ElectionCommission(models.Model):
    email = models.EmailField(unique=True, default="ec@referendum.gov.sr")
    password = models.CharField(max_length=255)

    class Meta:
        db_table = "election_commission"

    def set_password(self, raw_password):
        self.password = hashlib.sha256(raw_password.encode()).hexdigest()

    def check_password(self, raw_password):
        return self.password == hashlib.sha256(raw_password.encode()).hexdigest()


class Referendum(models.Model):
    STATUS_CHOICES = [
        ("open", "Open"),
        ("closed", "Closed"),
    ]

    title = models.TextField()
    description = models.TextField()
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default="closed")
    created_at = models.DateTimeField(auto_now_add=True)
    is_locked = models.BooleanField(default=False)

    class Meta:
        db_table = "referendums"


class ReferendumOption(models.Model):
    referendum = models.ForeignKey(
        Referendum, related_name="options", on_delete=models.CASCADE
    )
    option_text = models.TextField()
    vote_count = models.IntegerField(default=0)

    class Meta:
        db_table = "referendum_options"


class Vote(models.Model):
    voter = models.ForeignKey(Voter, on_delete=models.CASCADE)
    referendum = models.ForeignKey(Referendum, on_delete=models.CASCADE)
    option = models.ForeignKey(ReferendumOption, on_delete=models.CASCADE)
    voted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "votes"
        unique_together = ("voter", "referendum")
