import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/websocket_client.dart';
import '../../data/driver_service.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverService _driverService;
  final WebSocketClient _webSocketClient;

  DriverBloc(this._driverService, this._webSocketClient) : super(DriverInitialState()) {
    
    // Initialiser l'écoute en direct du serveur WebSocket pour l'acceptation de l'offre
    _webSocketClient.onEvent('bid_accepted', (data) {
      add(OnBidAcceptedEvent(data as Map<String, dynamic>));
    });

    // 1. Gestion de la soumission de l'offre (Bid)
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

    // 2. Gestion de la notification d'acceptation de l'offre
    on<OnBidAcceptedEvent>((event, emit) {
      emit(DriverJobAcceptedState(event.roleDetails)); // ou event.rideDetails selon l'état
    });

    // 3. Gestion de la mise à jour du statut physique du trajet (Arrivé départ, Démarré, Terminé)
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
  }

  @override
  Future<void> close() {
    // Nettoyer l'écouteur WebSocket pour éviter les fuites de mémoire
    _webSocketClient.offEvent('bid_accepted');
    return super.close();
  }
}
