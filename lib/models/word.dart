import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable()
class Word {
  final int code;
  final String msg;
  final WordData data;

  Word({required this.code, required this.msg, required this.data});

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}

@JsonSerializable()
class WordData {
  final String bookId;
  final List<Phrase> phrases;
  final List<RelWord> relWords;
  final List<Sentence> sentences;
  final List<Synonym> synonyms;
  final List<Translation> translations;
  final String ukphone;
  final String ukspeech;
  final String usphone;
  final String usspeech;
  final String word;

  WordData({
    required this.bookId,
    required this.phrases,
    required this.relWords,
    required this.sentences,
    required this.synonyms,
    required this.translations,
    required this.ukphone,
    required this.ukspeech,
    required this.usphone,
    required this.usspeech,
    required this.word,
  });

  factory WordData.fromJson(Map<String, dynamic> json) =>
      _$WordDataFromJson(json);
  Map<String, dynamic> toJson() => _$WordDataToJson(this);
}

@JsonSerializable()
class Phrase {
  final String p_cn;
  final String p_content;

  Phrase({required this.p_cn, required this.p_content});

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);
  Map<String, dynamic> toJson() => _$PhraseToJson(this);
}

@JsonSerializable()
class RelWord {
  final List<Hwd> Hwds;
  final String Pos;

  RelWord({required this.Hwds, required this.Pos});

  factory RelWord.fromJson(Map<String, dynamic> json) => _$RelWordFromJson(json);
  Map<String, dynamic> toJson() => _$RelWordToJson(this);
}

@JsonSerializable()
class Hwd {
  final String hwd;
  final String tran;

  Hwd({required this.hwd, required this.tran});

  factory Hwd.fromJson(Map<String, dynamic> json) => _$HwdFromJson(json);
  Map<String, dynamic> toJson() => _$HwdToJson(this);
}

@JsonSerializable()
class Sentence {
  final String s_cn;
  final String s_content;

  Sentence({required this.s_cn, required this.s_content});

  factory Sentence.fromJson(Map<String, dynamic> json) =>
      _$SentenceFromJson(json);
  Map<String, dynamic> toJson() => _$SentenceToJson(this);
}

@JsonSerializable()
class Synonym {
  final List<WordItem> Hwds;
  final String pos;
  final String tran;

  Synonym({required this.Hwds, required this.pos, required this.tran});

  factory Synonym.fromJson(Map<String, dynamic> json) => _$SynonymFromJson(json);
  Map<String, dynamic> toJson() => _$SynonymToJson(this);
}

@JsonSerializable()
class WordItem {
  final String word;

  WordItem({required this.word});

  factory WordItem.fromJson(Map<String, dynamic> json) =>
      _$WordItemFromJson(json);
  Map<String, dynamic> toJson() => _$WordItemToJson(this);
}

@JsonSerializable()
class Translation {
  final String pos;
  final String tran_cn;

  Translation({required this.pos, required this.tran_cn});

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}