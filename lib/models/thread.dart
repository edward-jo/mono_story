import 'package:json_annotation/json_annotation.dart';
import 'package:mono_story/constants.dart';

part 'thread.g.dart';

@JsonSerializable()
class Thread {
  @JsonKey(name: ThreadsTableCols.id)
  final int? id;
  @JsonKey(name: ThreadsTableCols.name)
  String name;

  Thread({this.id, required this.name});

  factory Thread.fromJson(Map<String, dynamic> json) => _$ThreadFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadToJson(this);
}
