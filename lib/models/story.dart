import 'package:json_annotation/json_annotation.dart';
import 'package:mono_story/constants.dart';

part 'story.g.dart';

@JsonSerializable()
class Story {
  @JsonKey(name: StoriesTableCols.id)
  final int? id;
  @JsonKey(name: StoriesTableCols.story)
  final String story;
  @JsonKey(name: StoriesTableCols.fkThreadId)
  final int? threadId;
  @JsonKey(name: StoriesTableCols.createdTime)
  final DateTime createdTime;
  @JsonKey(name: StoriesTableCols.starred)
  int starred;

  Story({
    this.id,
    required this.story,
    required this.threadId,
    required this.createdTime,
    required this.starred,
  });

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}
