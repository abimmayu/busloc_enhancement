//
//  StopPickerView.swift
//  busloc
//
//  Created by Atilla Rizkyara on 08/04/25.
//
import SwiftUI

struct StopPickerView: View {
    @Binding var selectedStop: String
    var allStops: [String]

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var filteredStops: [String] {
        if searchText.isEmpty {
            return allStops
        } else {
            return allStops.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search stop...", text: $searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
            .padding()

            List {
                ForEach(filteredStops, id: \.self) { stop in
                    Button(action: {
                        selectedStop = stop
                        dismiss()
                    }) {
                        Text(stop)
                            .foregroundColor(.black)
                    }
                }
                .listRowBackground(Color.white)
                .listRowSeparatorTint(.white)
            }
            .background(.white)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
        .background(.white)
        .navigationTitle("Select Stop")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isSearchFocused = true
            }
        }
    }
}

#Preview {
    StopPickerView(selectedStop: .constant(""), allStops: ["1", "2", "3"])
}

