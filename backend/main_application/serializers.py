from rest_framework import serializers
from .models import Voter, SCC, Referendum, ReferendumOption, Vote, ElectionCommission
from datetime import date


class VoterRegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    scc_code = serializers.CharField(write_only=True, max_length=10)

    class Meta:
        model = Voter
        fields = ["email", "full_name", "date_of_birth", "password", "scc_code"]

    def validate_date_of_birth(self, value):
        # ensure voter is at least 18 years old
        today = date.today()
        age = (
            today.year
            - value.year
            - ((today.month, today.day) < (value.month, value.day))
        )
        if age < 18:
            raise serializers.ValidationError("Voter must be at least 18 years old")
        return value

    def validate_scc_code(self, value):
        # check SCC code exists and is unused
        try:
            scc = SCC.objects.get(code=value)
            if scc.is_used:
                raise serializers.ValidationError("SCC code has already been used")
        except SCC.DoesNotExist:
            raise serializers.ValidationError("Invalid SCC code")
        return value

    def create(self, validated_data):
        # create voter and mark SCC as used
        scc_code = validated_data.pop("scc_code")
        password = validated_data.pop("password")

        scc = SCC.objects.get(code=scc_code)
        voter = Voter.objects.create(scc=scc, **validated_data)
        voter.set_password(password)
        voter.save()

        scc.is_used = True
        scc.save()

        return voter


class VoterLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class ECLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class ReferendumOptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReferendumOption
        fields = ["id", "option_text", "vote_count"]
        read_only_fields = ["vote_count"]


class ReferendumSerializer(serializers.ModelSerializer):
    options = ReferendumOptionSerializer(many=True, required=False)

    class Meta:
        model = Referendum
        fields = ["id", "title", "description", "status", "options", "is_locked"]
        read_only_fields = ["is_locked"]

    def create(self, validated_data):
        # create referendum and its options
        options_data = validated_data.pop("options", [])
        referendum = Referendum.objects.create(**validated_data)

        for option_data in options_data:
            ReferendumOption.objects.create(referendum=referendum, **option_data)

        return referendum

    def update(self, instance, validated_data):
        # prevent editing key fields once referendum is locked
        if instance.is_locked and (
            "title" in validated_data
            or "description" in validated_data
            or "options" in validated_data
        ):
            raise serializers.ValidationError(
                "Cannot modify locked referendum details"
            )

        options_data = validated_data.pop("options", None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)

        # automatically lock when opened
        if instance.status == "open" and not instance.is_locked:
            instance.is_locked = True

        instance.save()

        if options_data and not instance.is_locked:
            instance.options.all().delete()
            for option_data in options_data:
                ReferendumOption.objects.create(referendum=instance, **option_data)

        return instance


class ReferendumVoterSerializer(serializers.ModelSerializer):
    options = ReferendumOptionSerializer(many=True, required=False)
    voted = serializers.SerializerMethodField()
    option = serializers.SerializerMethodField()

    class Meta:
        model = Referendum
        fields = ["id", "title", "description", "status", "options", "voted", "option"]

    def get_voted(self, obj):
        # check if voter has already voted
        voter = self.context["request"].user
        return Vote.objects.filter(referendum=obj.id, voter=voter).exists()

    def get_option(self, obj):
        # return chosen option if voter has voted
        voter = self.context["request"].user
        vote = Vote.objects.filter(referendum=obj.id, voter=voter).first()
        if vote:
            return ReferendumOptionSerializer(vote.option).data
        return " "


class VoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vote
        fields = ["referendum", "option"]

    def validate(self, data):
        voter = self.context["request"].user
        referendum = data["referendum"]
        option = data["option"]

        # voting rules validation
        if referendum.status != "open":
            raise serializers.ValidationError("Referendum is not open for voting")

        if option.referendum != referendum:
            raise serializers.ValidationError(
                "Option does not belong to this referendum"
            )

        if Vote.objects.filter(voter=voter, referendum=referendum).exists():
            raise serializers.ValidationError(
                "You have already voted in this referendum"
            )

        return data

    def create(self, validated_data):
        # save vote and update counts
        voter = self.context["request"].user
        vote = Vote.objects.create(voter=voter, **validated_data)

        option = validated_data["option"]
        option.vote_count += 1
        option.save()

        # close referendum if 50% threshold reached
        total_voters = Voter.objects.count()
        if option.vote_count >= total_voters * 0.5:
            referendum = validated_data["referendum"]
            referendum.status = "closed"
            referendum.save()

        return vote


class ReferendumAPISerializer(serializers.ModelSerializer):
    referendum_options = serializers.SerializerMethodField()

    class Meta:
        model = Referendum
        fields = ["id", "status", "title", "description", "referendum_options"]

    def get_referendum_options(self, obj):
        # custom options response format
        options = obj.options.all()
        return {
            "options": [
                {str(opt.id): opt.option_text, "votes": str(opt.vote_count)}
                for opt in options
            ]
        }

    def to_representation(self, instance):
        # rename fields for API response
        data = super().to_representation(instance)
        return {
            "referendum_id": str(data["id"]),
            "status": data["status"],
            "referendum_title": data["title"],
            "referendum_desc": data["description"],
            "referendum_options": data["referendum_options"],
        }
