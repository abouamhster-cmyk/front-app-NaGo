abstract class DriverEvent {}

// 1. Événement déclenché quand le conducteur reçoit la confirmation que son offre est acceptée
class OnBidAcceptedEvent extends DriverEvent {
  final Map<String, dynamic> rideDetails;
  OnBidAcceptedEvent(this.rideDetails);
}

// 2. Action d'envoyer une proposition de prix (Bid)
class SubmitBidEvent extends DriverEvent {
  final String rideId;
  final double prixPropose;
  SubmitBidEvent(this.rideId, this.prixPropose);
}

// 3. Action de changer l'étape physique de la course (Arrivé départ, Démarré, Terminé)
class UpdateRideStatusEvent extends DriverEvent {
  final String rideId;
  final String nouveauStatut; // 'arrive_depart', 'en_cours', 'termine'
  UpdateRideStatusEvent(this.rideId, this.nouveauStatut);
}
