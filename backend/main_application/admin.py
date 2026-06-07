from django.contrib import admin
from .models import Voter, SCC, Referendum, ReferendumOption, Vote, ElectionCommission


@admin.register(SCC)
class SCCAdmin(admin.ModelAdmin):
    list_display = ["code", "is_used"]
    list_filter = ["is_used"]
    search_fields = ["code"]


@admin.register(Voter)
class VoterAdmin(admin.ModelAdmin):
    list_display = ["email", "full_name", "date_of_birth", "scc", "created_at"]
    search_fields = ["email", "full_name"]
    list_filter = ["created_at"]


@admin.register(ElectionCommission)
class ElectionCommissionAdmin(admin.ModelAdmin):
    list_display = ["email"]


class ReferendumOptionInline(admin.TabularInline):
    model = ReferendumOption
    extra = 2


@admin.register(Referendum)
class ReferendumAdmin(admin.ModelAdmin):
    list_display = ["id", "title", "status", "is_locked", "created_at"]
    list_filter = ["status", "is_locked"]
    search_fields = ["title"]
    inlines = [ReferendumOptionInline]


@admin.register(ReferendumOption)
class ReferendumOptionAdmin(admin.ModelAdmin):
    list_display = ["id", "referendum", "option_text", "vote_count"]
    list_filter = ["referendum"]


@admin.register(Vote)
class VoteAdmin(admin.ModelAdmin):
    list_display = ["voter", "referendum", "option", "voted_at"]
    list_filter = ["referendum", "voted_at"]
    search_fields = ["voter__email"]
