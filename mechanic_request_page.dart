import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_theme.dart';
import 'location_support_page.dart';

class MechanicRequestPage extends StatefulWidget {
  @override
  _MechanicRequestPageState createState() => _MechanicRequestPageState();
}

class _MechanicRequestPageState extends State<MechanicRequestPage> {
  String? _selectedService;
  double _urgencyLevel = 2;
  final _carModelController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  final _services = [
    "Engine Repair",
    "Brake Maintenance",
    "Electrical Diagnostics",
    "Suspension Check",
    "Oil Change",
    "Transmission Service"
  ];

  String get _urgencyLabel {
    if (_urgencyLevel <= 1) return "Routine";
    if (_urgencyLevel <= 2) return "Urgent";
    return "Emergency";
  }

  Color get _urgencyColor {
    if (_urgencyLevel <= 1) return Colors.green;
    if (_urgencyLevel <= 2) return Colors.orange;
    return AppTheme.accentColor;
  }

  @override
  void dispose() {
    _carModelController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationController.text = "Detecting location...");
    try {
      // Use IP-based location API (no geolocator/nuget required)
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _locationController.text = "${data['city']}, ${data['region']}, ${data['country_name']}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location detected: ${data['city']}")),
        );
      } else {
        throw "API Error";
      }
    } catch (e) {
      setState(() => _locationController.text = "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not detect location. Please enter manually.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request a Mechanic")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    bottom: -20,
                    child: Icon(Icons.build_circle, size: 180, color: Colors.white.withOpacity(0.08)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.handyman, color: Colors.white, size: 40),
                        SizedBox(height: 10),
                        Text(
                          "Professional Repair\nat Your Location",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Service Type ---
                  Text("Select Service Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: _services.map((s) => ChoiceChip(
                      label: Text(s),
                      selected: _selectedService == s,
                      onSelected: (selected) {
                        setState(() => _selectedService = selected ? s : null);
                      },
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(color: _selectedService == s ? Colors.white : Colors.black),
                    )).toList(),
                  ),

                  SizedBox(height: 30),

                  // --- Vehicle Details ---
                  Text("Vehicle Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextField(
                    controller: _carModelController,
                    decoration: InputDecoration(labelText: "Car Make & Model", prefixIcon: Icon(Icons.directions_car)),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Year", prefixIcon: Icon(Icons.calendar_today)),
                  ),

                  SizedBox(height: 30),

                  // --- Location ---
                  Text("Your Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: "Enter your address",
                      prefixIcon: Icon(Icons.location_on),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.my_location, color: AppTheme.accentColor),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LocationSupportPage()));
                    },
                    icon: Icon(Icons.map, color: AppTheme.primaryColor),
                    label: Text("Pick from Map"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- Urgency Level ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Urgency Level", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _urgencyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _urgencyLabel,
                          style: TextStyle(color: _urgencyColor, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _urgencyLevel,
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: _urgencyLabel,
                    onChanged: (v) {
                      setState(() => _urgencyLevel = v);
                    },
                    activeColor: _urgencyColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Routine", style: TextStyle(fontSize: 12, color: Colors.green)),
                      Text("Urgent", style: TextStyle(fontSize: 12, color: Colors.orange)),
                      Text("Emergency", style: TextStyle(fontSize: 12, color: AppTheme.accentColor)),
                    ],
                  ),

                  SizedBox(height: 30),

                  // --- Additional Notes ---
                  Text("Additional Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Describe the issue (optional)",
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.notes),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedService == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select a service type")),
                          );
                          return;
                        }
                        if (_locationController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please enter your location")),
                          );
                          return;
                        }
                        _showConfirmation(context);
                      },
                      child: Text("REQUEST MECHANIC NOW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Request Received!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              "Service: $_selectedService\nUrgency: $_urgencyLabel\nLocation: ${_locationController.text}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.6),
            ),
            SizedBox(height: 10),
            Text("A professional mechanic will contact you within 15 minutes.", textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Track Request"),
            ),
          ],
        ),
      ),
    );
  }
}
