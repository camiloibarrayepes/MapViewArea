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
}
