import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/qs_color_extension.dart';

class MapLocationPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapLocationPicker({super.key, this.initialLat, this.initialLng});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // إذا كان هناك موقع سابق محفوظ للمزود، نقوم بوضعه في الخريطة
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      // 🚀 إذا لم يوجد موقع سابق، نبحث عن الموقع الحالي تلقائياً فور فتح الشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
  }

  // 📍 دالة الحصول على الموقع الحالي (GPS)
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمات الموقع غير مفعلة')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    final newLocation = LatLng(position.latitude, position.longitude);
    
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 15));
    setState(() {
      _selectedLocation = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.qsColors;
    
    // 🌍 الإحداثيات الافتراضية في الكود (الرياض)
    final initialPos = _selectedLocation ?? const LatLng(24.7136, 46.6753);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('select_location')),
        centerTitle: true,
        actions: [
          // زر "تأكيد" يظهر فقط عند اختيار موقع
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton(
                onPressed: () => Navigator.pop(context, _selectedLocation),
                child: Text(
                  context.tr('confirm'),
                  style: TextStyle(
                    color: colors.primary, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // 🗺️ عرض الخريطة
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            // 📍 العلامة (Marker)
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                      infoWindow: const InfoWindow(title: 'موقعك المحدد'),
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // سنستخدم زرنا المخصص
            zoomControlsEnabled: false,
          ),
          
          // 🔘 زر "موقعي" (Floating Action Button)
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: colors.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          
          // 💡 تلميح للمستخدم في حال لم يحدد موقع بعد
          if (_selectedLocation == null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                    ],
                  ),
                  child: const Text(
                    'قم بالضغط على الخريطة لتحديد موقعك',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
