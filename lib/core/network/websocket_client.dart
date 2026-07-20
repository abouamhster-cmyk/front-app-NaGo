import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart'; // Pour récupérer l'adresse de base du serveur

class WebSocketClient {
  late io.Socket _socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Initialiser et connecter le canal WebSocket
  Future<void> connect() async {
    // Récupérer le token d'authentification de l'utilisateur
    final token = await _storage.read(key: "auth_token");

    if (token == null) {
      print("⚠️ Impossible de se connecter au WebSocket : Token introuvable.");
      return;
    }

    // Configuration de Socket.io avec le Handshake d'authentification
    _socket = io.io(
      ApiClient.baseUrl.replaceAll('/api', ''), // On vise la racine pour les sockets
      io.OptionBuilder()
          .setTransports(['websocket']) // Forcer l'utilisation de WebSocket
          .setAuth({'token': token})     // Injection sécurisée du Token JWT
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      print("🔌 Connecté avec succès au serveur WebSocket NaGo !");
    });

    _socket.onDisconnect((_) {
      print("🔌 Déconnecté du serveur WebSocket.");
    });

    _socket.onConnectError((data) {
      print("❌ Erreur de connexion WebSocket : $data");
    });
  }

  // Émettre (envoyer) la position GPS au serveur
  void emitLocation(double latitude, double longitude) {
    if (_socket.connected) {
      _socket.emit('update_location', {
        'latitude': latitude,
        'longitude': longitude,
      });
    }
  }

  // Se déconnecter proprement
  void disconnect() {
    _socket.disconnect();
  }

  bool get isConnected => _socket.connected;
}
