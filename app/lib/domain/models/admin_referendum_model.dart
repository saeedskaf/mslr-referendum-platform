class AdminReferendumModel {
  final List<AdminReferendum> referendums;

  AdminReferendumModel({required this.referendums});

  factory AdminReferendumModel.fromJson(List<dynamic> json) {
    return AdminReferendumModel(
      referendums: json.map((item) => AdminReferendum.fromJson(item)).toList(),
    );
  }
}

class AdminReferendum {
  final int id;
  final String title;
  final String description;
  final String status;
  final List<AdminReferendumOption> options;
  final bool isLocked;

  AdminReferendum({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.options,
    required this.isLocked,
  });

  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';

  int get totalVotes {
    return options.fold(0, (sum, option) => sum + option.voteCount);
  }

  factory AdminReferendum.fromJson(Map<String, dynamic> json) {
    return AdminReferendum(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      options: (json['options'] as List)
          .map((option) => AdminReferendumOption.fromJson(option))
          .toList(),
      isLocked: json['is_locked'],
    );
  }
}

class AdminReferendumOption {
  final int id;
  final String optionText;
  final int voteCount;

  AdminReferendumOption({
    required this.id,
    required this.optionText,
    required this.voteCount,
  });

  factory AdminReferendumOption.fromJson(Map<String, dynamic> json) {
    return AdminReferendumOption(
      id: json['id'],
      optionText: json['option_text'],
      voteCount: json['vote_count'],
    );
  }
}
