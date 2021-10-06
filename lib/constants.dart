import 'package:google_maps_flutter/google_maps_flutter.dart';

const MAP_API_KEY = 'AIzaSyC_Dj3ZmcVb3XG2OTJCH_NMU9l5e2zv95Q';
const minZoom = 12.0;
const CameraPosition kYaroslavlPos = CameraPosition(
  target: LatLng(57.62967635359928, 39.8791329190135),
  zoom: 15,
);
final kYaroslavlBounds = CameraTargetBounds(LatLngBounds(
  northeast: LatLng(57.73314725724288, 40.060845874249935),
  southwest: LatLng(57.4612200009501, 39.716095849871635),
));
