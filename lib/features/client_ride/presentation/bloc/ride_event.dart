abstract class RideEvent {}

// Action de chercher les conducteurs autour de la position actuelle du client
class GetNearbyDriversEvent extends RideEvent {
  final double latitude;
  final double longitude;
  GetNearbyDriversEvent(this.latitude, this.longitude);
}

// Déclenché en direct lorsque le conducteur déclare le montant reçu en espèces
class OnCashPaymentDeclaredEvent extends RideEvent {
  final Map<String, dynamic> paymentDetails;
  OnCashPaymentDeclaredEvent(this.paymentDetails);
}

// Action de lancer la réservation
class RequestRideEvent extends RideEvent {
  final String typeService;
  final String adresseDepart;
  final double latitudeDepart;
  final double longitudeDepart;
  final String adresseArrivee;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final double prixPropose;

  RequestRideEvent({
    required this.typeService,
    required this.adresseDepart,
    required this.latitudeDepart,
    required this.longitudeDepart,
    required this.adresseArrivee,
    required this.latitudeArrivee,
    required this.longitudeArrivee,
    required this.prixPropose,
  });
}
