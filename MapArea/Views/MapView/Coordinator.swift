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

        parent.viewModel.reCalculateAreaNLabels()
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

