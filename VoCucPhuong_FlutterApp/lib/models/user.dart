class AppUser {
  final String username;
  final String fullName;
  final String role; // admin | manager | staff | customer
  final String? scope; // NhapHang station scope
  final List<String> permissions;

  AppUser({
    required this.username,
    required this.fullName,
    required this.role,
    this.scope,
    this.permissions = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final raw = json['permissions'];
    List<String> perms = const [];
    if (raw is List) perms = raw.map((e) => e.toString()).toList();
    return AppUser(
      username: (json['username'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['username'] ?? '').toString(),
      role: (json['role'] ?? 'staff').toString(),
      scope: json['scope']?.toString(),
      permissions: perms,
    );
  }

  bool hasPerm(String key) => permissions.contains(key);
}
