//
//  MapSearchView.swift
//  busloc
//
//  Created by Abim on 09/05/25.
//

import SwiftUI
import MapKit

struct MapSearchView: View {
    // buatkan mapview dengan swiftUI
    @StateObject var viewModel: MapSearchViewModel = MapSearchViewModel()
    @GestureState private var dragOffset = CGSize.zero
    @StateObject private var keyboard = KeyboardResponder()


    
    var body: some View {
        NavigationStack {
            ZStack (alignment: .bottom) {
                MapPolylineView(
                    region: $viewModel.region,
                    polylines: viewModel.routeBusPolylines,
                    walkingPolylines: viewModel.walkingPolylines,
                    busStops: viewModel.busStopsForSelectedRoute,
                    userStartCoordinate: viewModel.startCoordinate,
                    userDestinationCoordinate: viewModel.destinationCoordinate
                )
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let userLocation = viewModel.locationManager.userLocation {
                            viewModel.setUserLocationAsStart(userLocation)
                        }
                    }
                }
                .foregroundColor(.white)
                
                SearchSheet(
                    viewModel: viewModel
                )
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 5)
                .offset(y: keyboard.currentHeight > 0 ? 100 : (viewModel.selectedDetent == .fraction(0.4) ? 500 : 300))
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            if value.translation.height > 50 {
                                viewModel.selectedDetent = .fraction(0.4)
                            } else if value.translation.height < -50 {
                                viewModel.selectedDetent = .medium
                            }
                        }
                )
                .animation(.easeInOut, value: viewModel.selectedDetent)
            }
        }
    }
}

struct SearchSheet: View {
    @StateObject var viewModel: MapSearchViewModel
    
    var body: some View {
        VStack {
            SearchBarLocation(viewModel: viewModel)
        }
    }
}

#Preview {
    MapSearchView()
}


// Background Interaction Enable True
// Path Sesuai Map
// Interactive Sheet
// State search enhancement
// Enhance route in the first build
// Make path for the route, same with the way
// Implementasi GameplayKit
// Implementasi MKDirection untuk path
