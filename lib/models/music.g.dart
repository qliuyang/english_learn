// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicApiResponse _$MusicApiResponseFromJson(Map<String, dynamic> json) =>
    MusicApiResponse(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => MusicData.fromJson(e as Map<String, dynamic>))
          .toList(),
      time: json['time'] as String,
      pid: (json['pid'] as num).toInt(),
      tips: json['tips'] as String,
    );

Map<String, dynamic> _$MusicApiResponseToJson(MusicApiResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
      'time': instance.time,
      'pid': instance.pid,
      'tips': instance.tips,
    };

MusicData _$MusicDataFromJson(Map<String, dynamic> json) => MusicData(
  id: (json['id'] as num).toInt(),
  mid: json['mid'] as String,
  vid: json['vid'] as String,
  song: json['song'] as String,
  subtitle: json['subtitle'] as String,
  album: json['album'] as String,
  singer: json['singer'] as String,
  singerList: (json['singer_list'] as List<dynamic>)
      .map((e) => SingerInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  cover: json['cover'] as String,
  pay: json['pay'] as String,
  time: json['time'] as String,
  type: (json['type'] as num).toInt(),
  bpm: (json['bpm'] as num).toInt(),
  content: json['content'] as String,
  quality: json['quality'] as String,
  grp: (json['grp'] as List<dynamic>)
      .map((e) => MusicData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MusicDataToJson(MusicData instance) => <String, dynamic>{
  'id': instance.id,
  'mid': instance.mid,
  'vid': instance.vid,
  'song': instance.song,
  'subtitle': instance.subtitle,
  'album': instance.album,
  'singer': instance.singer,
  'singer_list': instance.singerList,
  'cover': instance.cover,
  'pay': instance.pay,
  'time': instance.time,
  'type': instance.type,
  'bpm': instance.bpm,
  'content': instance.content,
  'quality': instance.quality,
  'grp': instance.grp,
};

SingerInfo _$SingerInfoFromJson(Map<String, dynamic> json) => SingerInfo(
  id: (json['id'] as num).toInt(),
  mid: json['mid'] as String,
  name: json['name'] as String,
  pmid: json['pmid'] as String,
  title: json['title'] as String,
  type: (json['type'] as num).toInt(),
  uin: (json['uin'] as num).toInt(),
);

Map<String, dynamic> _$SingerInfoToJson(SingerInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mid': instance.mid,
      'name': instance.name,
      'pmid': instance.pmid,
      'title': instance.title,
      'type': instance.type,
      'uin': instance.uin,
    };
