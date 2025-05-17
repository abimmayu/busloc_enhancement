//
//  SearchBarLocationView.swift
//  busloc
//
//  Created by Abim on 13/05/25.
//

import MapKit
import SwiftUI

struct SearchBarLocation: View {
    @StateObject private var locationManager: LocationManager = LocationManager()
    @StateObject var viewModel: MapSearchViewModel
    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                TextField(
                    "",
                    text: $viewModel.searchTextStart,
                    prompt: Text("Cari lokasi awal...")
                        .foregroundColor(.gray),
                )
                .foregroundColor(viewModel.searchTextStart.isEmpty ? .gray : .black)
                .onSubmit {
                    viewModel.performSearch()
                }
                .onTapGesture {
                    
                }
            }
            .padding()
            .background(.white)
            .clipShape(CustomRounded(radius: 20, corners: [.topLeft, .topRight],),)
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                TextField(
                    "",
                    text: $viewModel.searchTextDestination,
                    prompt: Text("Cari lokasi tujuan...")
                        .foregroundColor(.gray),
                )
                .foregroundColor(viewModel.searchTextDestination.isEmpty ? .gray : .black)
                .onSubmit {
                    viewModel.performSearch(isStartPoint: false)
                }
            }
            .padding()
            .background(.white)
            .clipShape(
                CustomRounded(
                    radius: 20,
                    corners:
                        [
                            .bottomLeft,
                            .bottomRight
                        ]
                )
            )
            if(!viewModel.searchResults.isEmpty) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchResults, id: \.self) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "Tidak diketahui")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)

                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                            }
                            .onTapGesture {
                                viewModel.changeStartPoint(to: item)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.top)
                }
                .padding(
                    [.top], 20
                )
            }
            if(!viewModel.searchRouteResult.isEmpty) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchRouteResult, id: \.self) { item in
                            RouteResultCard(
                                time: "\(item.totalDuration)",
                                routeName: "Rute \(item.route.busNumber)",
                                route: "\(item.stopNames.first!) - \(item.stopNames.last!)",
                                stopcount: item.numberOfStops,
                            )
                            .onTapGesture {
                                viewModel.selectedRoute = item
                            }
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding([.bottom], 12)
                        }
                    }
                }
                .padding(
                    [.top], 20
                )
            }
            Spacer()
        }
        .onAppear{
            if locationManager.userLocation != nil {
                viewModel.performSearch()
            }
        }
        .padding()
    }
}

#Preview {
    SearchBarLocation(viewModel: MapSearchViewModel())
}
