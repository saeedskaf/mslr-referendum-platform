class VoterReferendumModel {
  List<VoterReferendum> referendums;

  VoterReferendumModel({required this.referendums});

  factory VoterReferendumModel.fromJson(List<dynamic> json) {
    return VoterReferendumModel(
      referendums: json.map((item) => VoterReferendum.fromJson(item)).toList(),
    );
  }
}

class VoterReferendum {
  String id;
  String title;
  String description;
  String status;
  List<VoterOption> options;
  bool voted;
  VoterOption? selectedOption;

  VoterReferendum({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.options,
    required this.voted,
    this.selectedOption,
  });

  factory VoterReferendum.fromJson(Map<String, dynamic> json) {
    return VoterReferendum(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'closed',
      options: (json['options'] as List)
          .map((opt) => VoterOption.fromJson(opt))
          .toList(),
      voted: json['voted'] ?? false,
      selectedOption:
          json['option'] != null &&
              json['option'] is Map &&
              json['option'].isNotEmpty
          ? VoterOption.fromJson(json['option'])
          : null,
    );
  }

  bool get isOpen => status.toLowerCase() == 'open';

  bool get isClosed => status.toLowerCase() == 'closed';

  int get totalVotes {
    return options.fold(0, (sum, opt) => sum + opt.voteCount);
  }
}

class VoterOption {
  String id;
  String text;
  int voteCount;

  VoterOption({required this.id, required this.text, required this.voteCount});

  factory VoterOption.fromJson(Map<String, dynamic> json) {
    return VoterOption(
      id: json['id'].toString(),
      text: json['option_text'] ?? '',
      voteCount: json['vote_count'] ?? 0,
    );
  }

  double getPercentage(int total) {
    if (total == 0) return 0;
    return (voteCount / total) * 100;
  }
}
