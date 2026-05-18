import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>> connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    return _channel!.stream.map((event) {
      try {
        final decoded = json.decode(event.toString());
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {"event": "raw", "data": decoded};
      } catch (e) {
        return {
          "event": "error",
          "message": "Failed to decode WS message: ${e.toString()}",
        };
      }
    });
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(data));
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }
}
