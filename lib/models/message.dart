import 'package:json_annotation/json_annotation.dart';
import 'package:mono_story/constants.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: MessagesTableCols.id)
  final int? id;
  @JsonKey(name: MessagesTableCols.message)
  final String message;
  @JsonKey(name: MessagesTableCols.fkThreadId)
  final int? threadId;
  @JsonKey(name: MessagesTableCols.createdTime)
  final DateTime createdTime;

  Message({
    this.id,
    required this.message,
    required this.threadId,
    required this.createdTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
