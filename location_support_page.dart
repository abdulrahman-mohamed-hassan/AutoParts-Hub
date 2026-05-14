import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_theme.dart';

class LocationSupportPage extends StatefulWidget {
  @override
  _LocationSupportPageState createState() => _LocationSupportPageState();
}

class _LocationSupportPageState extends State<LocationSupportPage> {
  final TextEditingController _addressController = TextEditingController();
  String _currentLocation = "Auto-detecting...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _currentLocation = "${data['city']}, ${data['country_name']}";
          _addressController.text = _currentLocation;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = "Cairo, Egypt (Default)";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Support Location"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _detectLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          // High-Res Professional Map Simulation (Stable)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://images.unsplash.com/photo-1524661135-423995f22d0b?w=1200&q=80"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 60, color: AppTheme.accentColor),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Text(
                      _isLoading ? "Locating..." : "Your Car: $_currentLocation", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Search Overlay
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: "Enter address manually...",
                  prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                  suffixIcon: Icon(Icons.my_location, color: AppTheme.accentColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
          ),
          
          // Bottom Details Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Location Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.blue),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isLoading ? "Detecting real location..." : "Detected via Network: $_currentLocation", 
                          style: TextStyle(color: Colors.grey[700], fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Location confirmed at $_currentLocation")),
                        );
                        Navigator.pop(context);
                      },
                      child: Text("CONFIRM THIS LOCATION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
