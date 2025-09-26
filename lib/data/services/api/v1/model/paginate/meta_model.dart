import 'package:anttec_movil/data/services/api/v1/model/paginate/meta_links_model.dart';

class MetaModel {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<MetaLinksModel> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  MetaModel({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) {
    return MetaModel(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: (json['links'] as List)
          .map((e) => MetaLinksModel.fromJson(e))
          .toList(),
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}
