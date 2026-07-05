import re

E164_PATTERN = re.compile(r"^\+[1-9]\d{6,14}$")


def validate_phone(phone: str) -> bool:
    return bool(E164_PATTERN.match(phone))
