abstract class RideState {}

class RideInitialState extends RideState {}

class RideLoadingState extends RideState {}

// Conducteurs à proximité chargés avec succès (Permet de dessiner des marqueurs de motos sur la carte)
class NearbyDriversLoadedState extends RideState {
  final List<dynamic> drivers;
  NearbyDriversLoadedState(this.drivers);
}

// La demande est envoyée au serveur, on attend que les 3 à 5 conducteurs proposent leurs prix
class RideRequestSentState extends RideState {
  final Map<String, dynamic> rideDetails;
  RideRequestSentState(this.rideDetails);
}

class RideFailureState extends RideState {
  final String errorMessage;
  RideFailureState(this.errorMessage);
}
