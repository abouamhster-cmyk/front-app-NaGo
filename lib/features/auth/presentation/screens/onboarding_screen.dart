import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedRole = 'client'; // Par défaut
  String _selectedVehicle = 'zem'; // Par défaut pour les prestataires

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finalisez votre profil")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthenticatedState) {
                // Inscription réussie ! Redirection finale
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil créé ! Bienvenue sur NaGo."), backgroundColor: Colors.green),
                );
              } else if (state is AuthFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
                );
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: "Nom", border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: "Prénom", border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Âge", border: OutlineInputBorder()),
                      validator: (v) => v!.trim().isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Sélecteur de Rôle (Client vs Prestataire)
                    const Text("Vous êtes un :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Client"),
                            value: 'client',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text("Livreur/Chauffeur"),
                            value: 'prestataire',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() => _selectedRole = value!);
                            },
                          ),
                        ),
                      ],
                    ),

                    // Sélecteur de véhicule dynamique si Rôle = Prestataire
                    if (_selectedRole == 'prestataire') ...[
                      const SizedBox(height: 16),
                      const Text("Type de véhicule :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicle,
                        items: const [
                          DropdownMenuItem(value: 'zem', child: Text("Zemidjan (Moto)")),
                          DropdownMenuItem(value: 'voiture', child: Text("Voiture / Taxi")),
                          DropdownMenuItem(value: 'livreur', child: Text("Coursier (Vélo/Moto Simple)")),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedVehicle = v!);
                        },
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ],

                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: state is AuthLoadingState
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      CompleteOnboardingEvent(
                                        nom: _nomController.text.trim(),
                                        prenom: _prenomController.text.trim(),
                                        age: int.parse(_ageController.text.trim()),
                                        role: _selectedRole,
                                        typeVehicule: _selectedRole == 'prestataire' ? _selectedVehicle : null,
                                      ),
                                    );
                              }
                            },
                      child: state is AuthLoadingState
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text("Finaliser mon compte", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
