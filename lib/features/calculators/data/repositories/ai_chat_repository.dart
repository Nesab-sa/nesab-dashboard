import 'package:cloud_functions/cloud_functions.dart';

/// Repository that proxies chat messages to the AI backend via Cloud Functions.
/// The API key is stored server-side only – never exposed to the client.
class AiChatRepository {
  AiChatRepository({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  /// Sends a [message] to the AI chat proxy.
  /// [pageContext] describes the current page/calculator for better AI context.
  /// [conversationHistory] is a list of previous messages.
  /// Returns the AI response text on success, or throws on error.
  /// Returns a record of (reply, conversationId).
  Future<({String reply, String? conversationId})> sendMessage({
    required String message,
    String? pageContext,
    List<Map<String, String>>? conversationHistory,
    String? conversationId,
    String source = 'app',
  }) async {
    try {
      final callable = _functions.httpsCallable('aiChatProxy');
      final payload = <String, dynamic>{'message': message, 'source': source};
      if (pageContext != null && pageContext.isNotEmpty) {
        payload['pageContext'] = pageContext;
      }
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        payload['conversationHistory'] = conversationHistory;
      }
      if (conversationId != null && conversationId.isNotEmpty) {
        payload['conversationId'] = conversationId;
      }
      final result = await callable.call<Map<String, dynamic>>(payload);
      final data = result.data as Map<String, dynamic>?;
      return (
        reply: data?['reply'] as String? ?? '',
        conversationId: data?['conversationId'] as String?,
      );
    } on FirebaseFunctionsException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
