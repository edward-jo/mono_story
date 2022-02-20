import 'package:json_annotation/json_annotation.dart';
import 'package:mono_story/constants.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: StoriesTableCols.id)
  final int? id;
  @JsonKey(name: StoriesTableCols.story)
  final String message;
  @JsonKey(name: StoriesTableCols.fkThreadId)
  final int? threadId;
  @JsonKey(name: StoriesTableCols.createdTime)
  final DateTime createdTime;
  @JsonKey(name: StoriesTableCols.starred)
  int starred;

  Message({
    this.id,
    required this.message,
    required this.threadId,
    required this.createdTime,
    required this.starred,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
