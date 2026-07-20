import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class RideService {
  final ApiClient _apiClient = ApiClient();

  // 1. Récupérer les conducteurs à proximité du client depuis Redis
  Future<List<dynamic>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radiusInMeters = 3000, // 3 km par défaut
  }) async {
    try {
      final response = await _apiClient.client.get(
        "/rides/nearby",
        queryParameters: {
          "lat": latitude,
          "lng": longitude,
          "radius": radiusInMeters,
        },
      );
      
      return response.data["drivers"] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erreur lors de la recherche des conducteurs.");
    }
  }

  // 2. Créer une nouvelle demande de course / livraison
  Future<Map<String, dynamic>> createRideRequest({
    required String typeService, // 'transport', 'course_achat', 'livraison_simple'
    required String adresseDepart,
    required double latitudeDepart,
    required double longitudeDepart,
    required String adresseArrivee,
    required double latitudeArrivee,
    required double longitudeArrivee,
    required double prixPropose,
  }) async {
    try {
      final response = await _apiClient.client.post(
        "/rides",
        data: {
          "type_service": typeService,
          "adresse_depart": adresseDepart,
          "latitude_depart": latitudeDepart,
          "longitude_depart": longitudeDepart,
          "adresse_arrivee": adresseArrivee,
          "latitude_arrivee": latitudeArrivee,
          "longitude_arrivee": longitudeArrivee,
          "prix_propose_client": prixPropose,
        },
      );

      return response.data["ride"] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erreur lors de la création de la réservation.");
    }
  }
}
