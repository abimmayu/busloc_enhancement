import SwiftUI

struct SearchView: View {
    @State private var startStop: String = ""
    @State private var endStop: String = ""
    @State private var isSelectingStart = false
    @State private var isSelectingEnd = false
    @State private var searchResults: [(bus: Bus, count: Int)] = []
    @State private var expandedBusNames: Set<String> = []
    @State private var showMap = false

    let items: [Bus] = busData
    var allStops: [String] {
        Set(items.flatMap { $0.route }).sorted()
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Find Best Route")
                        .foregroundColor(Color.black)
                        .font(.largeTitle)
                        .fontWeight(.bold)
//                    Spacer()
//                    Button {
//                        showMap = true
//                    } label: {
//                        Image(systemName: "map.circle.fill")
//                            .resizable()
//                            .frame(width: 48, height: 48)
//                            .foregroundColor(.orange)
//                    }
//                    .fullScreenCover(isPresented: $showMap) {
//                        MapSearchView()
//                    }
                }
                    
                // Starting Stop Picker
                VStack(alignment: .leading) {
                    NavigationLink(destination: StopPickerView(selectedStop: $startStop, allStops: allStops), isActive: $isSelectingStart) {
                        HStack {
                            Text(startStop.isEmpty ? "Select starting stop" : startStop)
                                .foregroundColor(startStop.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "magnifyingglass")
                        }
                        .padding()
                        .background(Color(.gray.withAlphaComponent(0.1)))
                        .cornerRadius(8)
//                        .padding(.horizontal)
                    }
                }

                // Destination Stop Picker
                VStack(alignment: .leading) {
                    NavigationLink(destination: StopPickerView(selectedStop: $endStop, allStops: allStops), isActive: $isSelectingEnd) {
                        HStack {
                            Text(endStop.isEmpty ? "Select destination stop" : endStop)
                                .foregroundColor(endStop.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "magnifyingglass")
                        }
                        .padding()
                        .background(Color(.gray.withAlphaComponent(0.1)))
                        .cornerRadius(8)
                    }
                }

                // Search Button
                Button("Find Best Route") {
                    searchResults = findAllValidRoutes(from: startStop, to: endStop)
                    expandedBusNames.removeAll()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Result Section
                if !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {

                            if let best = searchResults.first {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Best Route")
                                        .font(.title3)
                                        .bold()
                                        .padding(.bottom, 4)
                                        .padding(.horizontal)

                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "star.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(.orange)

                                            VStack(alignment: .leading) {
                                                Text(best.bus.name)
                                                    .font(.headline)
                                                Text("Total Stops: \(best.count + 1)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }

                                        Divider()

                                        DisclosureGroup("Show Route Stops") {
                                            VStack(alignment: .leading, spacing: 8) {
                                                ForEach(routeSegment(in: best.bus, from: startStop, to: endStop), id: \.self) { stop in
                                                    HStack(spacing: 8) {
                                                        Image(systemName: "circle.fill")
                                                            .resizable()
                                                            .frame(width: 8, height: 8)
                                                            .foregroundColor(.orange)
                                                        Text(stop)
                                                            .font(.subheadline)
                                                    }
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
                                        .font(.subheadline)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                            }

                            // Other Routes
                            if searchResults.count > 1 {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Other Available Routes")
                                        .font(.headline)
                                        .padding(.top)

                                    ForEach(searchResults.dropFirst(), id: \.bus.name) { result in
                                        DisclosureGroup(
                                            isExpanded: Binding(
                                                get: { expandedBusNames.contains(result.bus.name) },
                                                set: { isExpanded in
                                                    if isExpanded {
                                                        expandedBusNames.insert(result.bus.name)
                                                    } else {
                                                        expandedBusNames.remove(result.bus.name)
                                                    }
                                                }
                                            ),
                                            content: {
                                                VStack(alignment: .leading) {
                                                    ForEach(routeSegment(in: result.bus, from: startStop, to: endStop), id: \.self) { stop in
                                                        HStack {
                                                            Circle()
                                                                .fill(Color.gray.opacity(0.5))
                                                                .frame(width: 6, height: 6)
                                                            Text(stop)
                                                                .font(.caption)
                                                        }
                                                    }
                                                }
                                                .padding(.top, 5)
                                            },
                                            label: {
                                                VStack(alignment: .leading) {
                                                    HStack {
                                                        Image(systemName: "bus.fill")
                                                        Text(result.bus.name)
                                                            .font(.subheadline)
                                                            .bold()
                                                    }
                                                    Text("Total Stops: \(result.count + 1)")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        )
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                } else if !startStop.isEmpty && !endStop.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)
                            .padding(.top, 30)
                        Text("Sorry, route is unavailable")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer()
            }
            .padding(.horizontal)
            .background(Color.white)
        }
    }

    func findAllValidRoutes(from start: String, to end: String) -> [(bus: Bus, count: Int)] {
          let directRoutes = items.compactMap { bus -> (Bus, Int)? in
              guard let startIndex = bus.route.firstIndex(of: start),
                    let endIndex = bus.route.firstIndex(of: end),
                    startIndex < endIndex else {
                  return nil
              }
              let count = endIndex - startIndex
              return (bus, count)
          }

          if !directRoutes.isEmpty {
              return directRoutes.sorted(by: { $0.1 < $1.1 })
          }

          let loopingRoutes = items.compactMap { bus -> (Bus, Int)? in
              guard let startIndex = bus.route.firstIndex(of: start),
                    let endIndex = bus.route.firstIndex(of: end) else {
                  return nil
              }

              if endIndex < startIndex {
                  let count = (bus.route.count - startIndex) + endIndex
                  return (bus, count)
              }

              return nil
          }

          return loopingRoutes.sorted(by: { $0.1 < $1.1 })
      }

      func routeSegment(in bus: Bus, from start: String, to end: String) -> [String] {
          guard let startIndex = bus.route.firstIndex(of: start),
                let endIndex = bus.route.firstIndex(of: end) else {
              return []
          }

          if start == end {
              return [start]
          }

          if startIndex < endIndex {
              return Array(bus.route[startIndex...endIndex])
          } else {
              let toEnd = bus.route[startIndex..<bus.route.count]
              let fromStart = bus.route[0...endIndex]
              return Array(toEnd + fromStart)
          }
      }
}

#Preview {
    SearchView()
}
