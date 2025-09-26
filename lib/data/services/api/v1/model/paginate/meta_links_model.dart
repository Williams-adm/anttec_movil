class MetaLinksModel {
  final String? url;
  final String label;
  final bool active;

  MetaLinksModel({
    required this.url,
    required this.label,
    required this.active,
  });

  factory MetaLinksModel.fromJson(Map<String, dynamic> json) {
    return MetaLinksModel(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
