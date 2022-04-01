// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) => Story(
      id: json['_id'] as int?,
      story: json['story'] as String,
      threadId: json['fk_thread_id'] as int?,
      createdTime: DateTime.parse(json['created_time'] as String),
      starred: json['starred'] as int,
    );

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      '_id': instance.id,
      'story': instance.story,
      'fk_thread_id': instance.threadId,
      'created_time': instance.createdTime.toIso8601String(),
      'starred': instance.starred,
    };
