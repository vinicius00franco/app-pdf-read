import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/gemini_service.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendQuestion extends ChatEvent {
  final String question;
  final String? context;
  SendQuestion(this.question, {this.context});
}

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatStreaming extends ChatState {
  final String partial;
  ChatStreaming(this.partial);
  @override
  List<Object?> get props => [partial];
}
class ChatComplete extends ChatState {
  final String full;
  ChatComplete(this.full);
  @override
  List<Object?> get props => [full];
}
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IGeminiService gemini;
  ChatBloc(this.gemini) : super(ChatInitial()) {
    on<SendQuestion>(_onSend);
  }

  Future<void> _onSend(SendQuestion event, Emitter<ChatState> emit) async {
    final tokens = _estimateTokens(event.context ?? '');
    if (tokens > 30000) {
      emit(ChatError('Contexto acima de 30k tokens. Reduza o intervalo.'));
      return;
    }
    final buffer = StringBuffer();
    await emit.forEach(gemini.streamChatResponse(event.question, pdfContext: event.context), onData: (chunk) {
      buffer.write(chunk);
      return ChatStreaming(buffer.toString());
    });
    emit(ChatComplete(buffer.toString()));
  }

  int _estimateTokens(String text) {
    final len = text.length;
    return (len / 4).ceil();
  }
}