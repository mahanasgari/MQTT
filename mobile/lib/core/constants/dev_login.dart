/// Dev-only OTP bypass helpers. Production builds never call these.
const Set<String> kDevLoginBypassPhones = <String>{};

const String kDevLoginBypassCode = '000000';

bool isDevLoginBypassPhone(String phone) =>
    kDevLoginBypassPhones.contains(phone.trim());
