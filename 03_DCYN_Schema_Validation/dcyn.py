class DCYNValidationError(Exception):
    """Raised when a payload value cannot be unambiguously resolved to Y or N."""
    pass


def deconstruct_payload(value) -> str:
    """
    Deconstructs compliance inputs into a strict 'Y' or 'N' string.
    Rejects any ambiguous values, nulls, or unexpected types immediately.
    """
    if isinstance(value, bool):
        return "Y" if value else "N"
    
    if isinstance(value, str):
        cleaned = value.strip().lower()
        if cleaned in ("y", "yes", "true", "1"):
            return "Y"
        elif cleaned in ("n", "no", "false", "0"):
            return "N"
            
    raise DCYNValidationError(
        f"Ambiguous or invalid compliance value: '{value}'. "
        "Must resolve explicitly to Y or N."
    )