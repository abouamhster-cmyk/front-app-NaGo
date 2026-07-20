import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/websocket_client.dart';
import '../../data/ride_service.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final RideService _rideService;
  final WebSocketClient _webSocketClient;

  RideBloc(this._rideService, this._webSocketClient) : super(RideInitialState()) {
    
    // NOUVEAU : Écouter en direct si le prestataire déclare avoir reçu les espèces
    _webSocketClient.onEvent('cash_payment_declared', (data) {
      add(OnCashPaymentDeclaredEvent(data as Map<String, dynamic>));
    });

    on<GetNearbyDriversEvent>((event, emit) async {
      emit(RideLoadingState());
      try {
        final drivers = await _rideService.getNearbyDrivers(
          latitude: event.latitude,
          longitude: event.longitude,
        );
        emit(NearbyDriversLoadedState(drivers));
      } catch (e) {
        emit(RideFailureState(e.toString()));
      }
    });

    on<RequestRideEvent>((event, emit) async {
      emit(RideLoadingState());
      try {
        final ride = await _rideService.createRideRequest(
          typeService: event.typeService,
          adresseDepart: event.adresseDepart,
          latitudeDepart: event.latitudeDepart,
          longitudeDepart: event.longitudeDepart,
          adresseArrivee: event.adresseArrivee,
          latitudeArrivee: event.latitudeArrivee,
          longitudeArrivee: event.longitudeArrivee,
          prixPropose: event.prixPropose,
        );
        emit(RideRequestSentState(ride));
      } catch (e) {
        emit(RideFailureState(e.toString()));
      }
    });

    // NOUVEAU : Traiter l'événement de déclaration d'espèces reçu en direct
    on<OnCashPaymentDeclaredEvent>((event, emit) {
      emit(CashPaymentValidationRequiredState(event.paymentDetails));
    });
  }

  @override
  Future<void> close() {
    // Libérer l'écouteur WebSocket pour éviter les fuites de mémoire
    _webSocketClient.offEvent('cash_payment_declared');
    return super.close();
  }
}
