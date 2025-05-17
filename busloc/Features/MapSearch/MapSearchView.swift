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

    
    var body: some View {
        NavigationStack {
            MapPolylineView(region: $viewModel.region, polylines: viewModel.routePolylines, busStops: viewModel.busStopsForSelectedRoute)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let userLocation = viewModel.locationManager.userLocation {
                            viewModel.setUserLocationAsStart(userLocation)
                        }
                    }
                }
                .sheet(
                    isPresented: .constant(true),
                    content: {
                        SearchSheet(viewModel: viewModel)
                            .presentationDetents([.fraction(0.2), .medium], selection: $viewModel.selectedDetent)
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled(true)
                            .presentationBackground(.white)
                    }
                )
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
