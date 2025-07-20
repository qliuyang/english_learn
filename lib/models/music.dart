import 'package:json_annotation/json_annotation.dart';

part 'music.g.dart';

@JsonSerializable()
class MusicApiResponse {
  final int code;
  final String message;
  final List<MusicData> data;
  final String time;
  final int pid;
  final String tips;

  MusicApiResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.time,
    required this.pid,
    required this.tips,
  });

  factory MusicApiResponse.fromJson(Map<String, dynamic> json) =>
      _$MusicApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MusicApiResponseToJson(this);
}

@JsonSerializable()
class MusicData {
  final int id;
  final String mid;
  final String vid;
  final String song;
  final String subtitle;
  final String album;
  final String singer;
  @JsonKey(name: 'singer_list')
  final List<SingerInfo> singerList;
  final String cover;
  final String pay;
  final String time;
  final int type;
  final int bpm;
  final String content;
  final String quality;
  final List<MusicData> grp;

  MusicData({
    required this.id,
    required this.mid,
    required this.vid,
    required this.song,
    required this.subtitle,
    required this.album,
    required this.singer,
    required this.singerList,
    required this.cover,
    required this.pay,
    required this.time,
    required this.type,
    required this.bpm,
    required this.content,
    required this.quality,
    required this.grp,
  });

  factory MusicData.fromJson(Map<String, dynamic> json) =>
      _$MusicDataFromJson(json);
  Map<String, dynamic> toJson() => _$MusicDataToJson(this);
}

@JsonSerializable()
class SingerInfo {
  final int id;
  final String mid;
  final String name;
  final String pmid;
  final String title;
  final int type;
  final int uin;

  SingerInfo({
    required this.id,
    required this.mid,
    required this.name,
    required this.pmid,
    required this.title,
    required this.type,
    required this.uin,
  });

  factory SingerInfo.fromJson(Map<String, dynamic> json) =>
      _$SingerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SingerInfoToJson(this);
}