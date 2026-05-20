import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Manages a single WebSocket connection for the KARIGAR app.
///
/// Usage:
/// ```dart
/// final client = WebSocketClient();
/// final stream = client.connect('ws://127.0.0.1:8000/ws/agent-stream');
/// client.send({'query': '...', 'session_id': '...'});
/// // on dispose:
/// client.disconnect();
/// ```
class WebSocketClient {
  WebSocketChannel? _channel;

  /// Opens a connection to [url] and returns a broadcast stream of decoded
  /// JSON messages.  Each message is a `Map<String, dynamic>`.
  Stream<Map<String, dynamic>> connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    return _channel!.stream.map((event) {
      try {
        final decoded = json.decode(event.toString());
        if (decoded is Map<String, dynamic>) return decoded;
        return <String, dynamic>{'event': 'raw', 'data': decoded};
      } catch (e) {
        return <String, dynamic>{
          'event': 'error',
          'message': 'Failed to decode WS message: ${e.toString()}',
        };
      }
    });
  }

  /// Sends a JSON-encoded [data] map over the open channel.
  /// Silently no-ops if the channel is not yet connected.
  void send(Map<String, dynamic> data) {
    _channel?.sink.add(json.encode(data));
  }

  /// Closes the WebSocket connection gracefully.
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
