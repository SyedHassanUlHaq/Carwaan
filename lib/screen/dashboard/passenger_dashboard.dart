import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PassengerDashboard extends StatefulWidget {
  const PassengerDashboard({super.key});

  @override
  _PassengerDashboardState createState() => _PassengerDashboardState();
}

class _PassengerDashboardState extends State<PassengerDashboard> {
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  bool isSelectingPickup = true;
  bool isFindingDriver = false;
  bool driverFound = false;
  BuildContext? _dialogContext;
  double? estimatedFare;
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  /// Fetch locations from OpenStreetMap's Nominatim API
  Future<void> _searchLocation(String query, bool isPickup) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = json.decode(response.body);
      setState(() {
        _searchResults = results
            .map((place) => {
                  'display_name': place['display_name'],
                  'lat': double.parse(place['lat']),
                  'lon': double.parse(place['lon'])
                })
            .toList();
      });
    }
  }

  /// Update the selected location on the map
  void _setLocation(Map<String, dynamic> place, bool isPickup) {
    setState(() {
      LatLng location = LatLng(place['lat'], place['lon']);
      if (isPickup) {
        pickupLocation = location;
        _pickupController.text = place['display_name'];
      } else {
        dropoffLocation = location;
        _dropoffController.text = place['display_name'];
      }

      // Calculate fare when both locations are selected
      if (pickupLocation != null && dropoffLocation != null) {
        estimatedFare = _calculateFare(pickupLocation!, dropoffLocation!);
      }

      _searchResults.clear(); // Hide dropdown after selection
    });
  }

  /// Calculate fare based on distance
  double _calculateFare(LatLng pickup, LatLng dropoff) {
    final Distance distance = Distance();
    final distanceInMeters = distance.as(LengthUnit.Meter, pickup, dropoff);
    return distanceInMeters * 0.025; // $1 per km
  }

  /// Show the "Finding a Driver..." dialog
  void _showRideDialog() {
    setState(() {
      isFindingDriver = true;
      driverFound = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _dialogContext = context;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: Text(
                driverFound ? "Driver Found!" : "Finding a Driver...",
                style: const TextStyle(color: Colors.white),
              ),
              content: driverFound
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("A driver is on the way!", style: TextStyle(color: Colors.white)),
                        if (estimatedFare != null)
                          Text("Estimated Fare: \$${estimatedFare!.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.lightBlue)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.lightBlue),
                        const SizedBox(height: 10),
                        const Text("Searching for a nearby driver...", style: TextStyle(color: Colors.white)),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: _closeDialog,
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );

    // Simulate finding a driver after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isFindingDriver = false;
          driverFound = true;
        });
        _closeDialog();
        _showRideDialog(); // Optionally show the driver found dialog
      }
    });
  }

  // Close the dialog
  void _closeDialog() {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// OpenStreetMap using Flutter Map
          FlutterMap(
            options: MapOptions(
              center: LatLng(24.8607, 67.0011),  // Coordinates for Karachi, Pakistan
              zoom: 13.0,
              onTap: (tapPosition, latlng) {
                setState(() {
                  if (isSelectingPickup) {
                    pickupLocation = latlng;
                    _pickupController.text = "Selected Location";
                    isSelectingPickup = false;
                  } else {
                    dropoffLocation = latlng;
                    _dropoffController.text = "Selected Location";
                    if (pickupLocation != null && dropoffLocation != null) {
                      estimatedFare = _calculateFare(pickupLocation!, dropoffLocation!);
                    }
                  }
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (pickupLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: pickupLocation!,
                      child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
                    ),
                  ],
                ),
              if (dropoffLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: dropoffLocation!,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),

          /// Search bars
          Positioned(
            top: 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildSearchBar(_pickupController, "Enter pickup location", true),
                const SizedBox(height: 10),
                _buildSearchBar(_dropoffController, "Enter drop-off location", false),
              ],
            ),
          ),

          /// Fare display
          if (estimatedFare != null)
            Positioned(
              bottom: 80,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Estimated Fare: PKR${estimatedFare!.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                ),
              ),
            ),
        ],
      ),

      /// Request Ride Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (pickupLocation != null && dropoffLocation != null) {
            _showRideDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select both locations.")),
            );
          }
        },
        label: const Text('Request Ride', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.local_taxi, color: Colors.white),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }

  /// Build a search bar with dropdown results
  Widget _buildSearchBar(TextEditingController controller, String hint, bool isPickup) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (query) => _searchLocation(query, isPickup),
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.search, color: Colors.black),
          ),
        ),
        if (_searchResults.isNotEmpty)
          Container(
            color: Colors.white,
            child: Column(
              children: _searchResults.map((place) {
                return ListTile(
                  title: Text(place['display_name'], style: const TextStyle(color: Colors.black)),
                  onTap: () => _setLocation(place, isPickup),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
