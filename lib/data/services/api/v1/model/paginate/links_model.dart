class LinksModel {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  LinksModel({required this.first, required this.last, this.prev, this.next});

  factory LinksModel.fromJson(Map<String, dynamic> json) {
    return LinksModel(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}
