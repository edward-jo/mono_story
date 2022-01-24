// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['_id'] as int?,
      message: json['message'] as String,
      threadNameId: json['fk_thread_id'] as int?,
      createdTime: DateTime.parse(json['created_time'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      '_id': instance.id,
      'message': instance.message,
      'fk_thread_id': instance.threadNameId,
      'created_time': instance.createdTime.toIso8601String(),
    };
