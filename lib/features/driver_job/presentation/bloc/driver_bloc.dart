import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/websocket_client.dart';
import '../../data/driver_service.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverService _driverService;
  final WebSocketClient _webSocketClient;

  DriverBloc(this._driverService, this._webSocketClient) : super(DriverInitialState()) {
    
    // Écouteur 1 : Le client valide l'offre (Déjà présent)
    _webSocketClient.onEvent('bid_accepted', (data) {
      add(OnBidAcceptedEvent(data as Map<String, dynamic>));
    });

    // NOUVEAU : Écouteur 2 - Le paiement en espèces est validé
    _webSocketClient.onEvent('payment_validated', (data) {
      add(OnPaymentValidatedEvent(data as Map<String, dynamic>));
    });

    // NOUVEAU : Écouteur 3 - Litige signalé, le compte est restreint
    _webSocketClient.onEvent('account_restricted', (data) {
      add(OnAccountRestrictedEvent(data as Map<String, dynamic>));
    });

    on<SubmitBidEvent>((event, emit) async {
      emit(DriverLoadingState());
      try {
        await _driverService.submitBid(
          rideId: event.rideId,
          prixPropose: event.prixPropose,
        );
        emit(BidSubmittedSuccessState());
      } catch (e) {
        emit(DriverFailureState(e.toString()));
      }
    });

    on<OnBidAcceptedEvent>((event, emit) {
      emit(DriverJobAcceptedState(event.rideDetails));
    });

    on<UpdateRideStatusEvent>((event, emit) async {
      emit(DriverLoadingState());
      try {
        final updatedRide = await _driverService.updateRideStatus(
          rideId: event.rideId,
          nouveauStatut: event.nouveauStatut,
        );
        emit(RideStatusUpdateSuccessState(updatedRide));
      } catch (e) {
        emit(DriverFailureState(e.toString()));
      }
    });

    // NOUVEAU : Traiter la validation du paiement en direct
    on<OnPaymentValidatedEvent>((event, emit) {
      emit(DriverPaymentValidatedState(event.data));
    });

    // NOUVEAU : Traiter la restriction du compte en direct
    on<OnAccountRestrictedEvent>((event, emit) {
      emit(DriverAccountRestrictedState(
        event.restrictionDetails['raison'] as String,
        event.restrictionDetails['fin_restriction'] as String,
      ));
    });
  }

  @override
  Future<void> close() {
    // Nettoyer tous les écouteurs pour éviter les fuites de mémoire
    _webSocketClient.offEvent('bid_accepted');
    _webSocketClient.offEvent('payment_validated');
    _webSocketClient.offEvent('account_restricted');
    return super.close();
  }
}
