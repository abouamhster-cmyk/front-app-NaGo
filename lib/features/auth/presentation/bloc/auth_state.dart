abstract class AuthState {}

// État initial (Écran vide, prêt pour saisie du numéro de téléphone)
class AuthInitialState extends AuthState {}

// État de chargement (Indicateur de progrès circulaire à l'écran)
class AuthLoadingState extends AuthState {}

// Le SMS a été envoyé avec succès, on attend que l'utilisateur saisisse le code
class OtpSentState extends AuthState {}

// L'OTP est validé, mais l'utilisateur doit maintenant finaliser son inscription
class OnboardingRequiredState extends AuthState {}

// L'utilisateur est authentifié et son inscription est finalisée (Prêt à aller à l'accueil)
class AuthenticatedState extends AuthState {
  final Map<String, dynamic> userProfile;
  AuthenticatedState(this.userProfile);
}

// En cas d'erreur (Mauvais numéro, code expiré, erreur serveur)
class AuthFailureState extends AuthState {
  final String errorMessage;
  AuthFailureState(this.errorMessage);
}
