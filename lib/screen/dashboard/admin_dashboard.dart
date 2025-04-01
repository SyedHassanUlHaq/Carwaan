import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<Map<String, dynamic>> activeRides = [
    {"id": 1, "pickup": LatLng(37.7749, -122.4194), "destination": "Downtown", "driver": "John Doe"},
    {"id": 2, "pickup": LatLng(37.7849, -122.4094), "destination": "Airport", "driver": "Jane Smith"},
    {"id": 3, "pickup": LatLng(37.7649, -122.4294), "destination": "Mall", "driver": "Alex Johnson"},
  ];

  final List<LatLng> activeDrivers = [
    LatLng(37.7740, -122.4140),
    LatLng(37.7840, -122.4040),
    LatLng(37.7640, -122.4240),
  ];

  int selectedRideIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildSummaryCard("Active Rides", activeRides.length.toString(), Colors.lightBlue),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard("Online Drivers", activeDrivers.length.toString(), Colors.green),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard("Passengers", "150", Colors.orange),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: 
            FlutterMap(
              options: MapOptions(
                center: LatLng(24.8607, 67.0011),  // Coordinates for Karachi, Pakistan
                zoom: 12.0,
                interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: activeDrivers.mapIndexed((index, driverLocation) {
                    return Marker(
                      width: 40,
                      height: 40,
                      point: driverLocation,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedRideIndex = index;
                          });
                        },
                        child: Icon(
                          Icons.directions_car,
                          color: selectedRideIndex == index ? Colors.yellow : Colors.lightBlue,
                          size: 30,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: activeRides.length,
              itemBuilder: (context, index) {
                final ride = activeRides[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedRideIndex = index;
                    });
                  },
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    color: selectedRideIndex == index ? Colors.grey[700] : Colors.grey[800],
                    child: ListTile(
                      title: Text("Ride to ${ride['destination']}", style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Driver: ${ride['driver']}", style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.directions_car, color: Colors.lightBlue),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center,),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center,),
          ],
        ),
      ),
    );
  }
}