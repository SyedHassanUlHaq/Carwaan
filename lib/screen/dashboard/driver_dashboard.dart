import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart'; // For formatting time

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  List<Map<String, dynamic>> rideRequests = [
    {
      "id": 1,
      "pickup": LatLng(37.7749, -122.4194),
      "destination": "Downtown",
      "passengerName": "Alice Johnson",
      "time": DateTime.now().add(Duration(minutes: 10)), // Example time
    },
    {
      "id": 2,
      "pickup": LatLng(37.7849, -122.4094),
      "destination": "Airport",
      "passengerName": "Bob Williams",
      "time": DateTime.now().add(Duration(minutes: 20)),
    },
    {
      "id": 3,
      "pickup": LatLng(37.7649, -122.4294),
      "destination": "Mall",
      "passengerName": "Charlie Davis",
      "time": DateTime.now().add(Duration(minutes: 30)),
    },
  ];

  LatLng? selectedPickup;

  void _acceptRide(int index) {
    setState(() {
      selectedPickup = rideRequests[index]['pickup'];
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMapScreen(
          pickupLocation: rideRequests[index]['pickup'],
          destination: rideRequests[index]['destination'],
          passengerName: rideRequests[index]['passengerName'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: rideRequests.length,
        itemBuilder: (context, index) {
          final ride = rideRequests[index];
          final formattedTime = DateFormat('hh:mm a').format(ride['time']); // Format time

          return Card(
            margin: EdgeInsets.all(8),
            color: Colors.grey[800], // Dark card color
            child: ListTile(
              title: Text("Ride to ${ride['destination']}", style: TextStyle(color: Colors.white)),
              subtitle: Column( // Use a Column for multiple lines
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pickup: ${ride['pickup'].latitude.toStringAsFixed(2)}, ${ride['pickup'].longitude.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.grey)),
                  Text("Passenger: ${ride['passengerName']}", style: TextStyle(color: Colors.grey)),
                  Text("Time: $formattedTime", style: TextStyle(color: Colors.grey)), // Display formatted time
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _acceptRide(index), // Pass the index
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Blue button
                ),
                child: Text("Accept", style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RideMapScreen extends StatelessWidget {
  final LatLng pickupLocation;
  final String destination;
  final String passengerName;

  const RideMapScreen({super.key, required this.pickupLocation, required this.destination, required this.passengerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride to $destination", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack( // Use a Stack to overlay information
        children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(24.8607, 67.0011),  // Coordinates for Karachi, Pakistan
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: pickupLocation,
                  child: Icon(Icons.location_pin, color: Colors.lightBlue, size: 40),
                ),
              ],
            ),
          ],
        ),
          Positioned( // Positioned widget for ride info
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7), // Semi-transparent background
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Passenger: $passengerName", style: TextStyle(color: Colors.white, fontSize: 16)),
                  Text("Destination: $destination", style: TextStyle(color: Colors.white, fontSize: 16)),
                  // Add more ride details here if needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}