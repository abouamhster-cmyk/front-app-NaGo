import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitialState()) {
    
    // 1. Gestion de l'envoi de l'OTP
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await _authService.sendOtp(event.phoneNumber);
        emit(OtpSentState());
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    // 2. Gestion de la vérification de l'OTP
    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final authResponse = await _authService.verifyOtp(event.phoneNumber, event.smsCode);
        
        // Si Supabase confirme la connexion
        if (authResponse.user != null) {
          // On vérifie si l'utilisateur est déjà inscrit dans PostgreSQL
          // (Si le profil n'existe pas encore, on déclenche la finalisation)
          // Pour l'instant, on redirige vers l'écran de finalisation par défaut :
          emit(OnboardingRequiredState());
        } else {
          emit(AuthFailureState("Une erreur d'authentification s'est produite."));
        }
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    // 3. Gestion de la finalisation d'inscription
    on<CompleteOnboardingEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final profile = await _authService.completeOnboarding(
          nom: event.nom,
          prenom: event.prenom,
          age: event.age,
          role: event.role,
          typeVehicule: event.typeVehicule,
        );
        emit(AuthenticatedState(profile));
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });

    // 4. Gestion de la déconnexion
    on<SignOutEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await _authService.signOut();
        emit(AuthInitialState());
      } catch (e) {
        emit(AuthFailureState(e.toString()));
      }
    });
  }
}
