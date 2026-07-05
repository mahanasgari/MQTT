class Share {
  final String id;
  final String granteePhone;
  final String scope;
  final String scopeId;
  final String permission;
  final String status;
  final String createdAt;

  const Share({
    required this.id,
    required this.granteePhone,
    required this.scope,
    required this.scopeId,
    required this.permission,
    required this.status,
    required this.createdAt,
  });

  factory Share.fromJson(Map<String, dynamic> json) => Share(
        id: json['id'] as String,
        granteePhone: json['grantee_phone'] as String? ?? '',
        scope: json['scope'] as String? ?? '',
        scopeId: json['scope_id'] as String? ?? '',
        permission: json['permission'] as String? ?? 'view',
        status: json['status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String? ?? '',
      );
}

class ShareCreateRequest {
  final String targetPhone;
  final String scope;
  final String scopeId;
  final String permission;

  const ShareCreateRequest({
    required this.targetPhone,
    required this.scope,
    required this.scopeId,
    required this.permission,
  });

  Map<String, dynamic> toJson() => {
        'target_phone': targetPhone,
        'scope': scope,
        'scope_id': scopeId,
        'permission': permission,
      };
}

class ShareUpdateRequest {
  final String status;
  const ShareUpdateRequest({required this.status});
  Map<String, dynamic> toJson() => {'status': status};
}
