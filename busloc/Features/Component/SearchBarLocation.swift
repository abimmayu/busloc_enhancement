//
//  SearchBarLocationView.swift
//  busloc
//
//  Created by Abim on 13/05/25.
//

import MapKit
import SwiftUI

struct SearchBarLocation: View {
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            TextField(
                "Cari lokasi di BSD",
                text: $searchText,
                onCommit: performSearch
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            TextField(
                "Cari lokasi di BSD 2",
                text: $searchText,
                onCommit: performSearch
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // Hasil pencarianApp
            List(searchResults, id: \.self) { item in
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(item.name ?? "Tidak diketahui")
                            .font(.headline)
                        if let address = item.placemark.title {
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }

    }

    func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(searchText) BSD"

        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: -6.3054,
                longitude: 106.6544
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                self.searchResults = response.mapItems.filter { item in
                    (item.name?.localizedCaseInsensitiveContains("BSD") ?? false)
                        || (item.placemark.title?
                            .localizedCaseInsensitiveContains("BSD") ?? false)
                }
            } else {
                self.searchResults = []
            }
        }
    }
}

#Preview {
    SearchBarLocation()
}
