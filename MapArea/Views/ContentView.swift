import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()

    var body: some View {
        VStack {
            MapView(region: $mapViewModel.region,
                    mapType: $mapViewModel.mapType,
                    annotations: $mapViewModel.annotations,
                    polyline: $mapViewModel.polyline,
                    distanceLabels: $mapViewModel.distanceLabels,
                    areaOverlay: $mapViewModel.areaOverlay,
                    areaLabel: $mapViewModel.areaLabel,
                    areaInSquareMeters: $mapViewModel.areaInSquareMeters)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button(action: {
                    mapViewModel.clearMapData()
                }) {
                    Text("Clear Pins")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Text("Area: \(String(format: "%.2f m²", mapViewModel.areaInSquareMeters))")
                    .padding()
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}
