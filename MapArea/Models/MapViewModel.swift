//
//  MapViewModel.swift
//  MapArea
//
//  Created by Camilo Ibarra yepes on 27/12/24.
//

import Foundation
import MapKit

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    @Published var mapType: MKMapType = .standard
    @Published var annotations: [MKPointAnnotation] = []
    @Published var polyline: MKPolyline? // Line between pins
    @Published var distanceLabels: [MKPointAnnotation] = [] // Distance labels
    @Published var areaOverlay: MKPolygon? // Closed area
    @Published var areaLabel: MKPointAnnotation? // Area label
    @Published var areaInSquareMeters: Double = 0.0 // Area in square meters

    // Method to clear all map data
    func clearMapData() {
        annotations.removeAll()
        polyline = nil
        distanceLabels.removeAll()
        areaOverlay = nil
        areaLabel = nil
        areaInSquareMeters = 0.0
    }
    
    func undoLastAnnotation() {
        guard !annotations.isEmpty else { return }
        
        // Remove the last annotation
        annotations.removeLast()
        
        // Clear previous data
        polyline = nil
        distanceLabels.removeAll()
        areaOverlay = nil
        areaLabel = nil
        areaInSquareMeters = 0.0
        
        // Recalculate polylines and distances
        if annotations.count > 1 {
            let coordinates = annotations.map { $0.coordinate }
            polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            
            for i in 0..<coordinates.count - 1 {
                let location1 = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
                let location2 = CLLocation(latitude: coordinates[i + 1].latitude, longitude: coordinates[i + 1].longitude)
                let distance = location1.distance(from: location2)
                
                let midpoint = CLLocationCoordinate2D(
                    latitude: (coordinates[i].latitude + coordinates[i + 1].latitude) / 2,
                    longitude: (coordinates[i].longitude + coordinates[i + 1].longitude) / 2
                )
                
                let distanceLabel = MKPointAnnotation()
                distanceLabel.coordinate = midpoint
                distanceLabel.title = String(format: "%.2f meters", distance)
                distanceLabels.append(distanceLabel)
            }
        }
        
        // Recalculate area if enough points remain
        reCalculateAreaNLabels()
    }
    
    func reCalculateAreaNLabels() {
        if annotations.count >= 3 {
            let coordinates = annotations.map { $0.coordinate }
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            areaOverlay = polygon
            
            let area = calculateArea(of: polygon)
            areaInSquareMeters = area
            
            let areaAnnotation = MKPointAnnotation()
            areaLabel = areaAnnotation
            
            // Add distance label between first and last pin
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
            if distanceLabels.count > 3 {
                // delete the title from the line between the last and first pin
                distanceLabels.remove(at: distanceLabels.count - 2)
            }
            distanceLabels.append(distanceLabel)
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

}
