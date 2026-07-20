import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class DriverService {
  final ApiClient _apiClient = ApiClient();

  // Envoyer une proposition de prix (Bid) pour une course
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
}
