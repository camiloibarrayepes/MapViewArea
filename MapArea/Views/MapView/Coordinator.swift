//
//  Coordinator.swift
//  MapArea
//
//  Created by Camilo Ibarra yepes on 27/12/24.
//

import MapKit
import CoreLocation

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        let coordinate = (gesture.view as! MKMapView).convert(location, toCoordinateFrom: gesture.view)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        parent.annotations.append(annotation)

        if parent.annotations.count > 1 {
            let coordinates = parent.annotations.map { $0.coordinate }
            parent.polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

            let location1 = CLLocation(latitude: coordinates[coordinates.count - 2].latitude, longitude: coordinates[coordinates.count - 2].longitude)
            let location2 = CLLocation(latitude: coordinates[coordinates.count - 1].latitude, longitude: coordinates[coordinates.count - 1].longitude)
            let distance = location1.distance(from: location2)
            
            let midpoint = CLLocationCoordinate2D(
                latitude: (coordinates[coordinates.count - 2].latitude + coordinates[coordinates.count - 1].latitude) / 2,
                longitude: (coordinates[coordinates.count - 2].longitude + coordinates[coordinates.count - 1].longitude) / 2
            )
            
            let distanceLabel = MKPointAnnotation()
            distanceLabel.coordinate = midpoint
            distanceLabel.title = String(format: "%.2f meters", distance)
            parent.distanceLabels.append(distanceLabel)
        }

        if parent.annotations.count >= 3 {
            let coordinates = parent.annotations.map { $0.coordinate }
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            parent.areaOverlay = polygon
            
            let area = self.calculateArea(of: polygon)
            parent.areaInSquareMeters = area
            
            let center = self.polygonCenter(of: polygon)
            let areaLabel = MKPointAnnotation()
//            areaLabel.coordinate = center
//            areaLabel.title = String(format: "%.2f m²", area)
            parent.areaLabel = areaLabel

            let firstCoordinate = coordinates.first!
            let lastCoordinate = coordinates.last!
            let firstLocation = CLLocation(latitude: firstCoordinate.latitude, longitude: firstCoordinate.longitude)
            let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            
            let distanceBetweenFirstAndLast = firstLocation.distance(from: lastLocation)
            let midpoint = CLLocationCoordinate2D(
                latitude: (firstCoordinate.latitude + lastCoordinate.latitude) / 2,
                longitude: (firstCoordinate.longitude + lastCoordinate.longitude) / 2
            )
            
            let distanceLabel = MKPointAnnotation()
            distanceLabel.coordinate = midpoint
            distanceLabel.title = String(format: "%.2f meters", distanceBetweenFirstAndLast)
            if parent.distanceLabels.count > 3 {
                // delete the title from the line between the last and first pin
                parent.distanceLabels.remove(at: parent.distanceLabels.count - 2)
            }

            parent.distanceLabels.append(distanceLabel)
        }
    }

    func calculateArea(of polygon: MKPolygon) -> Double {
        let count = polygon.pointCount
        guard count >= 3 else { return 0.0 }

        var area: Double = 0.0
        var points = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(latitude: 0, longitude: 0), count: count)
        polygon.getCoordinates(&points, range: NSRange(location: 0, length: count))

        let earthRadius = 6378137.0

        for i in 0..<count {
            let point1 = points[i]
            let point2 = points[(i + 1) % count]

            let lat1 = point1.latitude * .pi / 180
            let lon1 = point1.longitude * .pi / 180
            let lat2 = point2.latitude * .pi / 180
            let lon2 = point2.longitude * .pi / 180

            area += lon1 * sin(lat2) - lon2 * sin(lat1)
        }

        area = abs(area) * earthRadius * earthRadius / 2.0
        return area
    }

    func polygonCenter(of polygon: MKPolygon) -> CLLocationCoordinate2D {
        var sumLat = 0.0
        var sumLon = 0.0
        let points = polygon.points()
        for i in 0..<polygon.pointCount {
            sumLat += points[i].coordinate.latitude
            sumLon += points[i].coordinate.longitude
        }
        return CLLocationCoordinate2D(latitude: sumLat / Double(polygon.pointCount), longitude: sumLon / Double(polygon.pointCount))
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        } else if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.3)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

