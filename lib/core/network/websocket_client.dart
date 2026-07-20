import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart';

class WebSocketClient {
  late io.Socket _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> connect() async {
    final token = await _storage.read(key: "auth_token");

    if (token == null) {
      print("⚠️ Impossible de se connecter au WebSocket : Token introuvable.");
      return;
    }

    _socket = io.io(
      ApiClient.baseUrl.replaceAll('/api', ''),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) => print("🔌 Connecté au serveur WebSocket NaGo !"));
    _socket.onDisconnect((_) => print("🔌 Déconnecté du serveur WebSocket."));
    _socket.onConnectError((data) => print("❌ Erreur de connexion WebSocket : $data"));
  }

  // NOUVEAU : Écouter un événement spécifique en direct (ex: 'new_bid_received')
  void onEvent(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  // NOUVEAU : Arrêter d'écouter un événement pour libérer de la mémoire
  void offEvent(String event) {
    _socket.off(event);
  }

  void emitLocation(double latitude, double longitude) {
    if (_socket.connected) {
      _socket.emit('update_location', {
        'latitude': latitude,
        'longitude': longitude,
      });
    }
  }

  void disconnect() {
    _socket.disconnect();
  }

  bool get isConnected => _socket.connected;
}
