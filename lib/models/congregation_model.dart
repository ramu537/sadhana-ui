/**
 * Data models for congregation management
 */

enum Role {
  guest('GUEST', 'Guest'),
  congregationHead('CONGREGATION_HEAD', 'Congregation Head'),
  superAdmin('SUPER_ADMIN', 'Super Admin');

  const Role(this.value, this.displayName);
  final String value;
  final String displayName;

  static Role fromString(String value) {
    switch (value) {
      case 'GUEST':
        return Role.guest;
      case 'CONGREGATION_HEAD':
        return Role.congregationHead;
      case 'SUPER_ADMIN':
        return Role.superAdmin;
      default:
        return Role.guest;
    }
  }
}

enum JoinRequestStatus {
  pending('PENDING', 'Pending'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected');

  const JoinRequestStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static JoinRequestStatus fromString(String value) {
    switch (value) {
      case 'PENDING':
        return JoinRequestStatus.pending;
      case 'APPROVED':
        return JoinRequestStatus.approved;
      case 'REJECTED':
        return JoinRequestStatus.rejected;
      default:
        return JoinRequestStatus.pending;
    }
  }
}

class Congregation {
  final int id;
  final String name;
  final String description;
  final String location;
  final String? address;
  final String? contactNumber;
  final String? contactEmail;
  final User? head;  // Make head optional
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Congregation({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.address,
    this.contactNumber,
    this.contactEmail,
    this.head,  // Make head optional
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Congregation.fromJson(Map<String, dynamic> json) {
    return Congregation(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      location: json['location'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      contactEmail: json['contactEmail'],
      head: json['head'] != null ? User.fromJson(json['head']) : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'address': address,
      'contactNumber': contactNumber,
      'contactEmail': contactEmail,
      'head': head?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class UserCongregation {
  final int id;
  final User user;
  final Congregation congregation;
  final DateTime joinedAt;
  final bool isActive;
  final Role roleInCongregation;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserCongregation({
    required this.id,
    required this.user,
    required this.congregation,
    required this.joinedAt,
    required this.isActive,
    required this.roleInCongregation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserCongregation.fromJson(Map<String, dynamic> json) {
    return UserCongregation(
      id: json['id'],
      user: User.fromJson(json['user']),
      congregation: Congregation.fromJson(json['congregation']),
      joinedAt: DateTime.parse(json['joinedAt']),
      isActive: json['isActive'] ?? true,
      roleInCongregation: Role.fromString(json['roleInCongregation']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'congregation': congregation.toJson(),
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
      'roleInCongregation': roleInCongregation.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class JoinRequest {
  final int id;
  final User user;
  final Congregation congregation;
  final String? message;
  final JoinRequestStatus status;
  final User? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  JoinRequest({
    required this.id,
    required this.user,
    required this.congregation,
    this.message,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'],
      user: User.fromJson(json['user']),
      congregation: Congregation.fromJson(json['congregation']),
      message: json['message'],
      status: JoinRequestStatus.fromString(json['status']),
      reviewedBy: json['reviewedBy'] != null ? User.fromJson(json['reviewedBy']) : null,
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewNotes: json['reviewNotes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'congregation': congregation.toJson(),
      'message': message,
      'status': status.value,
      'reviewedBy': reviewedBy?.toJson(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == JoinRequestStatus.pending;
  bool get isApproved => status == JoinRequestStatus.approved;
  bool get isRejected => status == JoinRequestStatus.rejected;
}

// Update the existing User class to include role information
class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final Role globalRole;
  final bool isAdmin;
  final List<Congregation> activeCongregations;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.globalRole = Role.guest,
    this.isAdmin = false,
    this.activeCongregations = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      photoUrl: json['profilePictureUrl'],
      globalRole: Role.fromString(json['globalRole'] ?? 'GUEST'),
      isAdmin: json['isAdmin'] ?? false,
      activeCongregations: (json['activeCongregations'] as List<dynamic>?)
          ?.map((c) => Congregation.fromJson(c))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureUrl': photoUrl,
      'globalRole': globalRole.value,
      'isAdmin': isAdmin,
      'activeCongregations': activeCongregations.map((c) => c.toJson()).toList(),
    };
  }

  bool get isSuperAdmin => globalRole == Role.superAdmin;
  bool get isCongregationHead => globalRole == Role.congregationHead;
  bool get isGuest => globalRole == Role.guest;
} 