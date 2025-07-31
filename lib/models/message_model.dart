import 'package:hive/hive.dart';

part 'message_model.g.dart';
@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final bool isUser;

  @HiveField(2)
  final DateTime time;

  @HiveField(3)
  final String chatId;

  @HiveField(4)
  final String? title; // ✅ make this nullable

  MessageModel({
    required this.text,
    required this.isUser,
    required this.time,
    required this.chatId,
    this.title, // ✅ keep optional
  });
}

