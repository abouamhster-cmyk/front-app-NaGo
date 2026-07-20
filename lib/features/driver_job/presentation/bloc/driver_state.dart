import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/websocket_client.dart';
import '../../data/driver_service.dart';
import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverService _driverService;
  final WebSocketClient _webSocketClient;

  DriverBloc(this._driverService, this._webSocketClient) : super(DriverInitialState()) {
    
    // Initialiser l'écoute en direct du serveur WebSocket
    _webSocketClient.onEvent('bid_accepted', (data) {
      // Dès que le serveur nous dit que notre offre est acceptée, on déclenche l'événement dans le BLoC
      add(OnBidAcceptedEvent(data as Map<String, dynamic>));
    });

    // 1. Gestion de la soumission de l'offre
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
      emit(DriverJobAcceptedState(event.rideDetails));
    });
  }

  @override
  Future<void> close() {
    // Nettoyer l'écouteur WebSocket pour éviter les fuites de mémoire
    _webSocketClient.offEvent('bid_accepted');
    return super.close();
  }
}


// Indique au chauffeur que la mission est validée avec succès
class DriverPaymentValidatedState extends DriverState {
  final Map<String, dynamic> data;
  DriverPaymentValidatedState(this.data);
}

// Bloque l'interface du chauffeur en affichant la notification de restriction de 2 jours
class DriverAccountRestrictedState extends DriverState {
  final String raison;
  final String finRestriction;
  DriverAccountRestrictedState(this.raison, this.finRestriction);
}
