import 'package:flutter_test/flutter_test.dart';
import 'package:safraa_passenger_app/core/services/directions_service.dart';

void main() {
  test('decodes the Google polyline reference example', () {
    final pts = DirectionsService.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    expect(pts.length, 3);
    expect(pts[0].latitude, closeTo(38.5, 1e-5));
    expect(pts[0].longitude, closeTo(-120.2, 1e-5));
    expect(pts[2].latitude, closeTo(43.252, 1e-5));
    expect(pts[2].longitude, closeTo(-126.453, 1e-5));
  });
}
