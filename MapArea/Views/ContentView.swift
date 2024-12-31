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
                    areaInSquareMeters: $mapViewModel.areaInSquareMeters,
                    viewModel: mapViewModel)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button(action: {
                    mapViewModel.clearMapData()
                }) {
                    Text("Clear Pins")
                        .padding()
                        .background(mapViewModel.annotations.isEmpty ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(mapViewModel.annotations.isEmpty)
                
                Button(action: {
                    mapViewModel.undoLastAnnotation()
                }) {
                    Text("Undo")
                        .padding()
                        .background(mapViewModel.annotations.count < 2 ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(mapViewModel.annotations.count < 2)

                Text("Area:\n\(String(format: "%.2f m²", mapViewModel.areaInSquareMeters))")
                    .padding()
                    .foregroundColor(.black)
                    .frame(minWidth: 150, maxWidth: 200, alignment: .leading)
                    .frame(height: 80)

            }
            .padding()
        }
    }
}
