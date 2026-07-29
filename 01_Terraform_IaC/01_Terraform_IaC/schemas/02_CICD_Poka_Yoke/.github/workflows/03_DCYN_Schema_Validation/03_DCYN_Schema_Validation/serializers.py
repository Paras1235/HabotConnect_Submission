import re
from rest_framework import serializers
from .dcyn import deconstruct_payload, DCYNValidationError


class StudentSupportIntakeSerializer(serializers.Serializer):
    student_id = serializers.CharField(
        max_length=36,
        min_length=36,
        allow_blank=False,
    )
    guardian_email = serializers.EmailField(max_length=254, required=True)
    has_diagnosis_on_file = serializers.CharField(required=True)
    guardian_consent_given = serializers.CharField(required=True)
    requires_lsa_support = serializers.CharField(required=True)
    assigned_region_owner = serializers.EmailField(max_length=254, required=True)

    def validate_student_id(self, value):
        uuidv4_regex = re.compile(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            re.IGNORECASE
        )
        if not uuidv4_regex.match(value):
            raise serializers.ValidationError("Invalid UUIDv4 format for student_id.")
        return value

    def validate_has_diagnosis_on_file(self, value):
        try:
            return deconstruct_payload(value)
        except DCYNValidationError as e:
            raise serializers.ValidationError(str(e))

    def validate_guardian_consent_given(self, value):
        try:
            resolved = deconstruct_payload(value)
            if resolved != "Y":
                raise serializers.ValidationError("guardian_consent_given must resolve to 'Y'.")
            return resolved
        except DCYNValidationError as e:
            raise serializers.ValidationError(str(e))

    def validate_requires_lsa_support(self, value):
        try:
            return deconstruct_payload(value)
        except DCYNValidationError as e:
            raise serializers.ValidationError(str(e))