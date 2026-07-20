abstract class DriverEvent {}

// Événement déclenché quand le conducteur reçoit la confirmation en direct que son offre est acceptée
class OnBidAcceptedEvent extends DriverEvent {
  final Map<String, dynamic> rideDetails;
  OnBidAcceptedEvent(this.rideDetails);
}

// Action d'envoyer une proposition de prix
class SubmitBidEvent extends DriverEvent {
  final String rideId;
  final double prixPropose;
  SubmitBidEvent(this.rideId, this.prixPropose);
}
