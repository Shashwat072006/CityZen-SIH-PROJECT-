import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// --- Configuration ---
// PASTE THE CURRENT, LIVE NGROK URL FROM YOUR TEAMMATE HERE
const String backendUrl =
    'https://ed3fe3b68f7a.ngrok-free.app/api'; // PASTE THE LIVE NGROK URL HERE
// Default location if GPS fails or permissions denied
const LatLng _defaultLocation = LatLng(12.8231, 80.0444); // Kattankulathur

// --- DEBUG: Define Headers ---
// Define headers globally to ensure consistency
const Map<String, String> ngrokHeaders = {
  'ngrok-skip-browser-warning': 'true',
};

void main() {
  runApp(const CityZenApp());
}

// --- Category Definition ---
class ReportCategory {
  final String name;
  final IconData icon;

  const ReportCategory({required this.name, required this.icon});
}

final List<ReportCategory> reportCategories = [
  const ReportCategory(name: 'Road & Infrastructure', icon: Icons.traffic),
  const ReportCategory(name: 'Sewage & Water', icon: Icons.water_drop),
  const ReportCategory(name: 'Waste Management', icon: Icons.delete),
  const ReportCategory(name: 'Streetlights', icon: Icons.lightbulb),
  const ReportCategory(name: 'Public Safety', icon: Icons.local_police),
  const ReportCategory(name: 'Other', icon: Icons.category),
];

class CityZenApp extends StatelessWidget {
  const CityZenApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityZen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[800]!),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.location_city,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to CityZen',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report civic issues in your area.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Login',
                              style: TextStyle(fontSize: 18)),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Main App Screen ---
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MapViewScreen(),
    const MyReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Reports',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Map View Screen ---
class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Set<Marker> _markers = {};
  bool _isLoadingData = true;
  bool _isLoadingMap = true;
  String? _errorMessage;
  BitmapDescriptor? _redDotIcon;
  BitmapDescriptor? _orangeDotIcon;
  BitmapDescriptor? _greenDotIcon;
  bool _iconsReady = false;
  LatLng _initialMapCenter = _defaultLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeMapAndLocation();
  }

  Future<void> _initializeMapAndLocation() async {
    await _getCurrentLocationForMapCenter();
    if (mounted && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_initialMapCenter));
    }
    await _createMarkerIcons();
    if (mounted) {
      setState(() {
        _iconsReady = true;
        _isLoadingMap = false;
      });
      await _fetchIssues();
    }
  }

  Future<void> _getCurrentLocationForMapCenter() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Showing default location.')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Location permissions denied. Showing default location.')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions permanently denied. Please enable in settings. Showing default location.')));
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _initialMapCenter = LatLng(position.latitude, position.longitude);
        });
        if (_mapController != null) {
          _mapController!
              .animateCamera(CameraUpdate.newLatLng(_initialMapCenter));
        }
      }
    } catch (e) {
      print("Error getting initial location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Error getting location: $e. Showing default location.')));
      }
    }
  }

  Future<BitmapDescriptor> _createColoredDot(Color color,
      {double size = 48.0}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = color;
    final double radius = size / 2;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

    canvas.drawCircle(Offset(radius, radius), radius - 4, paint);

    final img = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      print("Error creating dot icon: Image data is null");
      return BitmapDescriptor.defaultMarker;
    }
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<void> _createMarkerIcons() async {
    try {
      _redDotIcon = await _createColoredDot(Colors.red);
      _orangeDotIcon = await _createColoredDot(Colors.orange);
      _greenDotIcon = await _createColoredDot(Colors.green);
    } catch (e) {
      print("Error creating marker icons: $e");
      _redDotIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      _orangeDotIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      _greenDotIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Future<void> _fetchIssues() async {
    if (!_iconsReady || !mounted) return;

    try {
      setState(() {
        _isLoadingData = true;
        _errorMessage = null;
      });

      // --- DEBUG PRINT ---
      final targetUrl = Uri.parse('$backendUrl/issues');
      print("Fetching issues from URL: $targetUrl");
      print("Using headers: $ngrokHeaders");
      // --- END DEBUG PRINT ---

      final response = await http.get(
        targetUrl,
        headers: ngrokHeaders, // Use the globally defined headers
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // --- DEBUG PRINT ---
        print("Fetch successful! Status: 200");
        // print("Response Body: ${response.body}"); // Uncomment to see raw data
        // --- END DEBUG PRINT ---

        final List<dynamic> issuesJson = json.decode(response.body);
        final Set<Marker> markers = issuesJson
            .map((issue) {
              final lat = issue['latitude'] as double?;
              final lon = issue['longitude'] as double?;
              final status = issue['status'] as String?;
              final categoryName = issue['category'] as String?;
              final title = issue['title'] as String?;
              final id = issue['id']?.toString();

              if (lat == null ||
                  lon == null ||
                  status == null ||
                  title == null ||
                  id == null) {
                print("Skipping issue due to missing data: $issue");
                return null;
              }

              BitmapDescriptor markerIcon;
              switch (status) {
                case 'Resolved':
                  markerIcon = _greenDotIcon!;
                  break;
                case 'In Progress':
                  markerIcon = _orangeDotIcon!;
                  break;
                default:
                  markerIcon = _redDotIcon!;
              }

              return Marker(
                markerId: MarkerId(id),
                position: LatLng(lat, lon),
                infoWindow: InfoWindow(
                  title: title,
                  snippet:
                      'Category: ${categoryName ?? "N/A"} - Status: $status',
                ),
                icon: markerIcon,
              );
            })
            .whereType<Marker>()
            .toSet();

        setState(() {
          _markers = markers;
        });
      } else {
        final responseBody = response.body;
        // --- DEBUG PRINT ---
        print("Fetch failed! Status: ${response.statusCode}");
        print("Response Body: $responseBody"); // See what ngrok is sending back
        // --- END DEBUG PRINT ---
        throw Exception(
            'Failed to load issues from server. Status: ${response.statusCode}. Body might be HTML.');
      }
    } catch (e) {
      print('Error during fetch or processing issues: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error fetching issues:\n$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
    );
    if (result == true && mounted) {
      _fetchIssues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CityZen Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: (_isLoadingMap || _isLoadingData) ? null : _fetchIssues,
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoadingMap
              ? const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Getting current location...")
                    ]))
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _initialMapCenter,
                    zoom: 15,
                  ),
                  markers: _markers,
                  padding: const EdgeInsets.only(bottom: 60.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
          if (!_isLoadingMap && _isLoadingData)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.redAccent.withOpacity(0.95),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndRefresh,
        label: const Text('Report Issue'),
        icon: const Icon(Icons.add_location_alt_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// --- Report Issue Screen ---
class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({Key? key}) : super(key: key);

  @override
  _ReportIssueScreenState createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  File? _image;
  Position? _currentPosition;
  bool _isSubmitting = false;
  ReportCategory? _selectedCategory;
  bool _isFetchingLocation = false;
  bool _useManualLocation = false;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null && mounted) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isFetchingLocation = true;
      _useManualLocation = false;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permissions permanently denied. Please enable in settings.')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  void _setManualLocation() {
    FocusScope.of(context).unfocus();
    final lat = double.tryParse(_latitudeController.text);
    final lon = double.tryParse(_longitudeController.text);

    if (lat != null && lon != null) {
      if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
        setState(() {
          _currentPosition = Position(
              latitude: lat,
              longitude: lon,
              timestamp: DateTime.now(),
              accuracy: 0.0,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0);
          _useManualLocation = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Manual location set successfully!'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Invalid latitude (-90 to 90) or longitude (-180 to 180).')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please enter valid numbers for latitude and longitude.')),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!mounted || !_formKey.currentState!.validate()) {
      return;
    }

    if (_useManualLocation) {
      _setManualLocation();
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide a valid location (GPS or Manual).')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final targetUrl = Uri.parse('$backendUrl/issues');
      // --- DEBUG PRINT ---
      print("Submitting report to URL: $targetUrl");
      print("Using headers: $ngrokHeaders");
      // --- END DEBUG PRINT ---

      var request = http.MultipartRequest(
        'POST',
        targetUrl,
      );

      // Add headers to the multipart request as well
      request.headers.addAll(ngrokHeaders);

      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();
      request.fields['category'] = _selectedCategory!.name;

      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );

      final response = await request.send();

      if (!mounted) return;

      final responseStatusCode = response.statusCode;
      final responseBody = await response.stream.bytesToString();

      // --- DEBUG PRINT ---
      print("Submit response Status Code: $responseStatusCode");
      print("Submit response Body: $responseBody");
      // --- END DEBUG PRINT ---

      if (responseStatusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report Submitted Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        // Provide more context in the error message
        throw Exception(
            'Failed to submit report. Server responded with Status: $responseStatusCode, Body: $responseBody');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a New Issue')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<ReportCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: reportCategories.map((category) {
                  return DropdownMenuItem<ReportCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title / Headline',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_search,
                                size: 50, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            const Text('Select an Image',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(_image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200),
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _getImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- UPDATED: Location Section ---
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Issue Location",
                              style: Theme.of(context).textTheme.titleMedium),
                          Tooltip(
                            message: "Get Current GPS Location",
                            child: IconButton(
                              icon: Icon(Icons.my_location,
                                  color: Theme.of(context).primaryColor),
                              onPressed: _isFetchingLocation
                                  ? null
                                  : _getCurrentLocation,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isFetchingLocation)
                        const Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                      SizedBox(width: 8),
                                      Text("Fetching location...")
                                    ]))),

                      // Manual Input Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d*'))
                              ],
                              onChanged: (_) => setState(() {
                                _useManualLocation = true;
                              }), // Mark as manual input on change
                              validator: (value) {
                                if (_useManualLocation &&
                                    (value == null || value.isEmpty)) {
                                  return 'Required';
                                }
                                final num = double.tryParse(value ?? '');
                                if (_useManualLocation &&
                                    (num == null || num < -90 || num > 90)) {
                                  return 'Invalid (-90 to 90)';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^-?\d*\.?\d*'))
                              ],
                              onChanged: (_) => setState(() {
                                _useManualLocation = true;
                              }), // Mark as manual input on change
                              validator: (value) {
                                if (_useManualLocation &&
                                    (value == null || value.isEmpty)) {
                                  return 'Required';
                                }
                                final num = double.tryParse(value ?? '');
                                if (_useManualLocation &&
                                    (num == null || num < -180 || num > 180)) {
                                  return 'Invalid (-180 to 180)';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Button to explicitly use manual coordinates
                      Center(
                        child: OutlinedButton.icon(
                          icon:
                              const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text("Use Entered Coordinates"),
                          onPressed: _setManualLocation,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            side: BorderSide(color: Colors.green[700]!),
                          ),
                        ),
                      ),
                      // Display the currently set location (whether GPS or manual)
                      if (_currentPosition != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _useManualLocation
                                ? "(Using Manually Entered Location)"
                                : "(Using GPS Location)",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Submit Report'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- My Reports Screen ---
class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> mockReports = const [
    {
      'title': 'Large Pothole on Main St',
      'status': 'Pending',
      'date': '2025-09-14',
      'category': 'Road & Infrastructure'
    },
    {
      'title': 'Broken Streetlight near Park',
      'status': 'In Progress',
      'date': '2025-09-12',
      'category': 'Streetlights'
    },
    {
      'title': 'Garbage overflow at bus stop',
      'status': 'Resolved',
      'date': '2025-09-11',
      'category': 'Waste Management'
    },
    {
      'title': 'Leaking pipe on corner',
      'status': 'Pending',
      'date': '2025-09-15',
      'category': 'Sewage & Water'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: ListView.builder(
        itemCount: mockReports.length,
        itemBuilder: (context, index) {
          final report = mockReports[index];
          final status = report['status']!;
          final categoryName = report['category']!;

          final category = reportCategories.firstWhere(
              (c) => c.name == categoryName,
              orElse: () => reportCategories.last);

          Color statusColor;
          switch (status) {
            case 'Resolved':
              statusColor = Colors.green;
              break;
            case 'In Progress':
              statusColor = Colors.orange;
              break;
            default:
              statusColor = Colors.red;
          }
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              leading: Icon(category.icon,
                  color: Theme.of(context).primaryColor, size: 40),
              title: Text(report['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Category: $categoryName\nReported on: ${report['date']}'),
              isThreeLine: true,
              trailing: Chip(
                label: Text(
                  status,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
                backgroundColor: statusColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
