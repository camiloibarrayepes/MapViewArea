//
//  MapView.swift
//  MapArea
//
//  Created by Camilo Ibarra yepes on 27/12/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @Binding var annotations: [MKPointAnnotation]
    @Binding var polyline: MKPolyline?
    @Binding var distanceLabels: [MKPointAnnotation]
    @Binding var areaOverlay: MKPolygon? // Closed area
    @Binding var areaLabel: MKPointAnnotation? // Area label
    @Binding var areaInSquareMeters: Double // Area in square meters

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.region = region
        mapView.mapType = mapType
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations + (distanceLabels + [areaLabel].compactMap { $0 }))
        
        uiView.removeOverlays(uiView.overlays)
        
        if let polyline = polyline {
            uiView.addOverlay(polyline)
        }
        
        if let areaOverlay = areaOverlay {
            uiView.addOverlay(areaOverlay)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
