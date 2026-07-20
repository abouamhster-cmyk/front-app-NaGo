import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/ride_service.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final RideService _rideService;

  RideBloc(this._rideService) : super(RideInitialState()) {

    // 1. Récupérer les conducteurs proches
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

    // 2. Lancer la réservation d'un trajet ou d'une livraison
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
  }
}
