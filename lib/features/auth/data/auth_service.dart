import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 1. Envoyer le code OTP par SMS
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      throw Exception("Erreur d'envoi du SMS : ${e.toString()}");
    }
  }

  // 2. Valider le code OTP reçu par SMS
  Future<AuthResponse> verifyOtp(String phoneNumber, String token) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );

      if (response.session != null) {
        // Stocker le token JWT de manière hautement sécurisée sur le téléphone
        await _storage.write(key: "auth_token", value: response.session!.accessToken);
      }
      
      return response;
    } catch (e) {
      throw Exception("Code de vérification invalide ou expiré.");
    }
  }

  // 3. Finaliser l'inscription sur notre serveur Node.js (si nouvel utilisateur)
  Future<Map<String, dynamic>> completeOnboarding({
    required String nom,
    required String prenom,
    required int age,
    required String role, // 'client' ou 'prestataire'
    String? typeVehicule, // Obligatoire si rôle = 'prestataire'
  }) async {
    try {
      final response = await _apiClient.client.post(
        "/auth/register",
        data: {
          "nom": nom,
          "prenom": prenom,
          "age": age,
          "role": role,
          "type_vehicule": typeVehicule,
        },
      );

      return response.data;
    } on DioException catch (e) {
      final errorMessage = e.response?.data["message"] ?? "Erreur lors de la finalisation du profil.";
      throw Exception(errorMessage);
    }
  }

  // 4. Déconnexion
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _storage.delete(key: "auth_token");
  }
}
