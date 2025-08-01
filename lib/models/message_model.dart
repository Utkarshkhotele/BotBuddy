import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  bool isUser;

  @HiveField(2)
  DateTime time;

  @HiveField(3)
  String chatId;

  @HiveField(4)
  String? title;

  MessageModel({
    required this.text,
    required this.isUser,
    required this.time,
    required this.chatId,
    this.title,
  });

  MessageModel copyWith({
    String? text,
    bool? isUser,
    DateTime? time,
    String? chatId,
    String? title,
  }) {
    return MessageModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      time: time ?? this.time,
      chatId: chatId ?? this.chatId,
      title: title ?? this.title,
    );
  }
}


