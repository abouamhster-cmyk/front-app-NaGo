import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Adresse IP de votre serveur local ou URL de production (Render / AWS)
  static const String baseUrl = "http://YOUR_SERVER_IP:3000/api";

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15); // 15s de timeout
    _dio.options.receiveTimeout = const Duration(seconds: 15);

    // Ajout d'un intercepteur pour injecter automatiquement le Token JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Récupérer le token sécurisé depuis la mémoire du téléphone
          final token = await _storage.read(key: "auth_token");
          
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          
          options.headers["Content-Type"] = "application/json";
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Gestion globale des erreurs réseau (Ex: Token expiré)
          if (e.response?.statusCode == 401) {
            // Optionnel : Déclencher une déconnexion automatique de l'utilisateur
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
}
