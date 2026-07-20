import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  // 1. Appelé par le CONDUCTEUR : Déclarer la somme perçue en espèces
  Future<Map<String, dynamic>> declareCashPayment({
    required String rideId,
    required double montantRecu,
  }) async {
    try {
      final response = await _apiClient.client.post(
        "/payments/declare-cash",
        data: {
          "ride_id": rideId,
          "montant_recu": montantRecu,
        },
      );

      return response.data["payment"] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erreur lors de la déclaration du paiement.");
    }
  }

  // 2. Appelé par le CLIENT : Confirmer le montant ou déclencher un litige
  Future<void> validatePayment({
    required String paymentId,
    required bool isValid,
    String? raisonLitige, // Obligatoire si isValid est faux
  }) async {
    try {
      await _apiClient.client.post(
        "/payments/validate-cash",
        data: {
          "payment_id": paymentId,
          "is_valid": isValid,
          "raison_litige": raisonLitige,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Erreur lors de la validation du paiement.");
    }
  }
}
