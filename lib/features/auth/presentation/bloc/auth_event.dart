abstract class AuthEvent {}

// 1. Événement pour envoyer le SMS
class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  SendOtpEvent(this.phoneNumber);
}

// 2. Événement pour valider le code OTP saisi
class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String smsCode;
  VerifyOtpEvent(this.phoneNumber, this.smsCode);
}

// 3. Événement pour compléter l'inscription sur l'API Node.js
class CompleteOnboardingEvent extends AuthEvent {
  final String nom;
  final String prenom;
  final int age;
  final String role;
  final String? typeVehicule;

  CompleteOnboardingEvent({
    required this.nom,
    required this.prenom,
    required this.age,
    required this.role,
    this.typeVehicule,
  });
}

// 4. Événement de déconnexion
class SignOutEvent extends AuthEvent {}
