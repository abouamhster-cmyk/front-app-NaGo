import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class DriverService {
  final ApiClient _apiClient = ApiClient();

  // 1. Envoyer une proposition de prix (Bid) pour une course
  Future<Map<String, dynamic>> submitBid({
    required String rideId,
    required double prixPropose,
  }) async {
    try {
      final response = await _apiClient.client.post(
        "/rides/bid",
        data: {
          "ride_id": rideId,
          "prix_propose": prixPropose,
        },
      );

      return response.data["bid"] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erreur lors de l'envoi de votre offre.");
    }
  }

  // 2. Mettre à jour l'étape physique du trajet (Arrivé départ, Démarré, Terminé)
  Future<Map<String, dynamic>> updateRideStatus({
    required String rideId,
    required String nouveauStatut, // 'arrive_depart', 'en_cours', 'termine'
  }) async {
    try {
      final response = await _apiClient.client.patch(
        "/rides/status",
        data: {
          "ride_id": rideId,
          "nouveau_statut": nouveauStatut,
        },
      );

      return response.data["ride"] as Map<String, dynamic>;
    } on DioException catch (e) {
      final errorMessage = e.response?.data["message"] ?? "Erreur lors de la mise à jour de l'étape.";
      throw Exception(errorMessage);
    }
  }
}
