// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  code: (json['code'] as num).toInt(),
  msg: json['msg'] as String,
  data: WordData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'code': instance.code,
  'msg': instance.msg,
  'data': instance.data,
};

WordData _$WordDataFromJson(Map<String, dynamic> json) => WordData(
  bookId: json['bookId'] as String,
  phrases: (json['phrases'] as List<dynamic>)
      .map((e) => Phrase.fromJson(e as Map<String, dynamic>))
      .toList(),
  relWords: (json['relWords'] as List<dynamic>)
      .map((e) => RelWord.fromJson(e as Map<String, dynamic>))
      .toList(),
  sentences: (json['sentences'] as List<dynamic>)
      .map((e) => Sentence.fromJson(e as Map<String, dynamic>))
      .toList(),
  synonyms: (json['synonyms'] as List<dynamic>)
      .map((e) => Synonym.fromJson(e as Map<String, dynamic>))
      .toList(),
  translations: (json['translations'] as List<dynamic>)
      .map((e) => Translation.fromJson(e as Map<String, dynamic>))
      .toList(),
  ukphone: json['ukphone'] as String,
  ukspeech: json['ukspeech'] as String,
  usphone: json['usphone'] as String,
  usspeech: json['usspeech'] as String,
  word: json['word'] as String,
);

Map<String, dynamic> _$WordDataToJson(WordData instance) => <String, dynamic>{
  'bookId': instance.bookId,
  'phrases': instance.phrases,
  'relWords': instance.relWords,
  'sentences': instance.sentences,
  'synonyms': instance.synonyms,
  'translations': instance.translations,
  'ukphone': instance.ukphone,
  'ukspeech': instance.ukspeech,
  'usphone': instance.usphone,
  'usspeech': instance.usspeech,
  'word': instance.word,
};

Phrase _$PhraseFromJson(Map<String, dynamic> json) => Phrase(
  p_cn: json['p_cn'] as String,
  p_content: json['p_content'] as String,
);

Map<String, dynamic> _$PhraseToJson(Phrase instance) => <String, dynamic>{
  'p_cn': instance.p_cn,
  'p_content': instance.p_content,
};

RelWord _$RelWordFromJson(Map<String, dynamic> json) => RelWord(
  Hwds: (json['Hwds'] as List<dynamic>)
      .map((e) => Hwd.fromJson(e as Map<String, dynamic>))
      .toList(),
  Pos: json['Pos'] as String,
);

Map<String, dynamic> _$RelWordToJson(RelWord instance) => <String, dynamic>{
  'Hwds': instance.Hwds,
  'Pos': instance.Pos,
};

Hwd _$HwdFromJson(Map<String, dynamic> json) =>
    Hwd(hwd: json['hwd'] as String, tran: json['tran'] as String);

Map<String, dynamic> _$HwdToJson(Hwd instance) => <String, dynamic>{
  'hwd': instance.hwd,
  'tran': instance.tran,
};

Sentence _$SentenceFromJson(Map<String, dynamic> json) => Sentence(
  s_cn: json['s_cn'] as String,
  s_content: json['s_content'] as String,
);

Map<String, dynamic> _$SentenceToJson(Sentence instance) => <String, dynamic>{
  's_cn': instance.s_cn,
  's_content': instance.s_content,
};

Synonym _$SynonymFromJson(Map<String, dynamic> json) => Synonym(
  Hwds: (json['Hwds'] as List<dynamic>)
      .map((e) => WordItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  pos: json['pos'] as String,
  tran: json['tran'] as String,
);

Map<String, dynamic> _$SynonymToJson(Synonym instance) => <String, dynamic>{
  'Hwds': instance.Hwds,
  'pos': instance.pos,
  'tran': instance.tran,
};

WordItem _$WordItemFromJson(Map<String, dynamic> json) =>
    WordItem(word: json['word'] as String);

Map<String, dynamic> _$WordItemToJson(WordItem instance) => <String, dynamic>{
  'word': instance.word,
};

Translation _$TranslationFromJson(Map<String, dynamic> json) =>
    Translation(pos: json['pos'] as String, tran_cn: json['tran_cn'] as String);

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{'pos': instance.pos, 'tran_cn': instance.tran_cn};
