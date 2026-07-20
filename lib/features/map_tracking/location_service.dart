import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/websocket_client.dart';

class LocationService {
  final WebSocketClient _webSocketClient = WebSocketClient();
  StreamSubscription<Position>? _positionStreamSubscription;

  // 1. Demander les permissions de géolocalisation au téléphone
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le GPS du téléphone est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 2. Démarrer le suivi GPS en temps réel et l'envoi au serveur
  Future<void> startLocationTracking() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      print("⚠️ Autorisation GPS refusée.");
      return;
    }

    // Établir la connexion WebSocket sécurisée avec le serveur
    await _webSocketClient.connect();

    // Configuration optimale pour économiser la batterie du conducteur
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Haute précision GPS requise pour le transport
      distanceFilter: 5,               // Le téléphone n'émet de mise à jour que s'il a bougé de 5 mètres minimum !
    );

    // Écouter le flux de changement de position
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      // Envoyer instantanément les nouvelles coordonnées via WebSocket au serveur
      _webSocketClient.emitLocation(position.latitude, position.longitude);
      
      print("📍 GPS local émis : Lat ${position.latitude}, Lng ${position.longitude}");
    });
  }

  // 3. Arrêter le suivi (quand le conducteur se déconnecte)
  Future<void> stopLocationTracking() async {
    await _positionStreamSubscription?.cancel();
    _webSocketClient.disconnect();
    print("📍 Suivi GPS arrêté et WebSocket déconnecté.");
  }
}
