//
//  MapSearchViewModel.swift
//  busloc
//
//  Created by Abim on 15/05/25.
//

import Foundation
import MapKit
import SwiftUI
import GameplayKit

class MapSearchViewModel: ObservableObject {
    @Published var searchTextStart: String = ""
    @Published var searchTextDestination: String = ""
    @Published var searchTextStartCoordinate: MKMapItem?
    @Published var searchTextDestinationCoordinate: MKMapItem?
    @Published var searchResults: [MKMapItem] = []
    @Published var allBuses: [TheBus] = []
    @Published var allStops: [BusStop] = []
    @Published var allSchedule: [BusSchedule] = []
    @Published var searchRouteResult: [CompleteRouteOption] = []
    @Published private var isStartPointSearch: Bool = true
    @Published private(set) var locationManager: LocationManager = LocationManager()
    @Published var selectedDetent: PresentationDetent = .fraction(0.4)
    @Published var routePolylines: [MKPolyline] = []
    @Published var selectedRoute: CompleteRouteOption? {
        didSet {
            updatePolylineForSelectedRoute()
        }
    }
    @Published var routeBusPolylines: [MKPolyline] = []
    var busStopsForSelectedRoute: [BusStop] {
        guard let selectedRoute = selectedRoute else { return [] }
        let stopNames = Set(selectedRoute.route.route.map { $0.stopName.lowercased() })
        return allStops.filter { stopNames.contains($0.name.lowercased()) }
    }
    
    @Published var walkingPolylines: [MKPolyline] = []
    @Published var startCoordinate: CLLocationCoordinate2D?
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: -6.302802,
            longitude: 106.6494667
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.02,
            longitudeDelta: 0.02
        )
    )
    @Published var isLoadingRoutes: Bool = false
    @Published var errorText: String?
    
    init() {
        self.allBuses = buses
        self.allStops = busStops
        self.allSchedule = schedules
    }
    
    func setUserLocationAsStart(_ coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        self.searchTextStartCoordinate = mapItem
        self.startCoordinate = coordinate
        self.searchTextStart = mapItem.name == "Unknown Location" ? "Current Location" : mapItem.name ?? ""
        self.region.center = coordinate
    }
    
    func nearestStop(to location: CLLocationCoordinate2D, stops: [BusStop]) -> BusStop? {
        let current = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return stops.min(by: {
            let a = CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            let b = CLLocation(latitude: $1.latitude, longitude: $1.longitude)
            return current.distance(from: a) < current.distance(from: b)
        })
    }
    
    func mergeTodayWithTime(of original: Date) -> Date? {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: original)
        return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                             minute: timeComponents.minute ?? 0,
                             second: timeComponents.second ?? 0,
                             of: Date()) // base: hari ini
    }
    
    
    func findAllPossibleRoutes() {
        guard let userCoordinate = searchTextStartCoordinate?.placemark.coordinate,
              let destinationCoordinate = searchTextDestinationCoordinate?.placemark.coordinate else {
            print("❌ Lokasi awal/tujuan tidak valid")
            return
        }
        errorText = nil
        isLoadingRoutes = true

        DispatchQueue.global(qos: .userInitiated).async {
            let now = Date() // Waktu saat ini
            let oneHourFromNow = now.addingTimeInterval(3600) // 1 jam dari sekarang

            let startCL = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
            let endCL = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)

            let sortedStartStops = self.allStops.sorted {
                CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: startCL) <
                CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: startCL)
            }

            let sortedEndStops = self.allStops.sorted {
                CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: endCL) <
                CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: endCL)
            }

            let grouped = Dictionary(grouping: self.allSchedule) {
                BusKey(session: $0.session, busNumber: $0.busNumber)
            }

            var uniqueRoutes: [String: CompleteRouteOption] = [:]
            var foundRouteCount = 0
            let maxRoutes = 10

            for startStop in sortedStartStops {
                for endStop in sortedEndStops {
                    guard startStop.id != endStop.id else { continue }
                    
                    if foundRouteCount >= maxRoutes { break }
                    
                    let startStopCL = CLLocation(latitude: startStop.latitude, longitude: startStop.longitude)
                    let endStopCL = CLLocation(latitude: endStop.latitude, longitude: endStop.longitude)
                    
                    let walkStartTime = startCL.distance(from: startStopCL) / 1.4
                    let walkEndTime = endStopCL.distance(from: endCL) / 1.4
                    
                    for (key, list) in grouped {
                        if foundRouteCount >= maxRoutes { break }
                        let sortedSchedule = list.sorted { $0.arrivalTime < $1.arrivalTime }
                        
                        guard
                            let startIdx = sortedSchedule.firstIndex(where: { $0.stopName.lowercased() == startStop.name.lowercased() }),
                            let endIdx = sortedSchedule.firstIndex(where: { $0.stopName.lowercased() == endStop.name.lowercased() }),
                            startIdx < endIdx
                        else { continue }
                        
                        let slicedRoute = Array(sortedSchedule[startIdx...endIdx])
                        guard
                            let rawTime = slicedRoute.first?.arrivalTime,
                            let startTime = self.mergeTodayWithTime(of: rawTime)
                                
                        else { continue }
                        
                        
                        // ✅ Hanya ambil bus yang berangkat dalam 1 jam dari sekarang
                        guard startTime >= now, startTime <= oneHourFromNow else { continue }
                        
                        let duration = Int(ceil(slicedRoute.last!.arrivalTime.timeIntervalSince(rawTime) / 60))
                        
                        let routeOption = BusRouteOption(
                            session: key.session,
                            busNumber: key.busNumber,
                            route: slicedRoute,
                            duration: duration
                        )
                        
                        let completeOption = CompleteRouteOption(
                            route: routeOption,
                            walkingTimeToStart: walkStartTime / 60,
                            walkingTimeToEnd: walkEndTime / 60
                        )
                        
                        // ✅ Buat key unik berdasar startID-endID-busNumber
                        let uniqueKey = "\(startStop.id)-\(endStop.id)-\(key.busNumber)"
                        if let existing = uniqueRoutes[uniqueKey] {
                            let existingTime = existing.route.route.first?.arrivalTime ?? Date.distantFuture
                            if startTime < existingTime {
                                uniqueRoutes[uniqueKey] = completeOption
                                foundRouteCount += 1
                            }
                        } else {
                            uniqueRoutes[uniqueKey] = completeOption
                            foundRouteCount += 1
                        }
                    }
                }
                if foundRouteCount >= maxRoutes { break }
            }

            DispatchQueue.main.async {
                let finalResults = Array(uniqueRoutes.values)
                    .sorted(by: { $0.totalDuration < $1.totalDuration })

                self.searchRouteResult = finalResults
                self.isLoadingRoutes = false

                if finalResults.isEmpty {
                    self.errorText = "Tidak ditemukan rute dalam 1 jam ke depan."
                    print("❌ Tidak ditemukan rute dalam 1 jam ke depan.")
                } else {
                    print("✅ Ditemukan \(finalResults.count) rute unik terbaik dalam 1 jam ke depan.")
                }
            }
        }
    }
    
    private func requestWalkingRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (MKRoute?) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                completion(route)
            } else {
                completion(nil)
            }
        }
    }

    private func requestBusRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping (MKRoute?) -> Void) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile // Simulasi trayek bus

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                completion(route)
            } else {
                completion(nil)
            }
        }
    }
    
    func updatePolylineForSelectedRoute() {
        DispatchQueue.main.async {
            self.selectedDetent = .fraction(0.4)
        }

        guard let selectedRoute = selectedRoute else {
            self.routePolylines = []
            self.walkingPolylines = []
            self.routeBusPolylines = []
            return
        }

        let coordinates: [CLLocationCoordinate2D] = selectedRoute.route.route.compactMap { schedule in
            if let stop = allStops.first(where: { $0.name.lowercased() == schedule.stopName.lowercased() }) {
                return CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
            } else {
                return nil
            }
        }

        self.routePolylines = [] // not used anymore
        self.routeBusPolylines = []
        self.walkingPolylines = []

        guard let userLoc = startCoordinate, let destinationLoc = destinationCoordinate else {
            return
        }

        if coordinates.count >= 2 {
            let group = DispatchGroup()

            for i in 0..<(coordinates.count - 1) {
                let from = coordinates[i]
                let to = coordinates[i + 1]

                group.enter()
                requestBusRoute(from: from, to: to) { route in
                    if let route = route {
                        DispatchQueue.main.async {
                            self.routeBusPolylines.append(route.polyline)
                        }
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                print("✅ Semua segmen rute bus telah dihitung.")
            }
        }

        if let firstStop = coordinates.first, let lastStop = coordinates.last {
            requestWalkingRoute(from: userLoc, to: firstStop) { startRoute in
                if let startRoute = startRoute {
                    DispatchQueue.main.async {
                        self.walkingPolylines.append(startRoute.polyline)
                    }
                }
            }
            requestWalkingRoute(from: lastStop, to: destinationLoc) { endRoute in
                if let endRoute = endRoute {
                    DispatchQueue.main.async {
                        self.walkingPolylines.append(endRoute.polyline)
                    }
                }
            }
        }

        if let first = coordinates.first {
            DispatchQueue.main.async {
                self.region.center = first
            }
        }
    }

    func performSearch(isStartPoint: Bool = true) {
        let request = MKLocalSearch.Request()
        isStartPointSearch = isStartPoint
        errorText = nil
        selectedDetent = .medium
        request.naturalLanguageQuery = "\(isStartPoint ? searchTextStart: searchTextDestination) BSD"

        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: -6.3054,
                longitude: 106.6544
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    self.searchRouteResult.removeAll()
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
    
    func changeStartPoint(to coordinate: MKMapItem) {
        DispatchQueue.main.async {
            if self.isStartPointSearch {
                self.searchTextStartCoordinate = coordinate
                self.startCoordinate = coordinate.placemark.coordinate
                self.searchTextStart = coordinate.name ?? ""
                self.region.center = coordinate.placemark.coordinate
                self.selectedDetent = .fraction(0.4)
            } else {
                self.searchTextDestinationCoordinate = coordinate
                self.destinationCoordinate = coordinate.placemark.coordinate
                self.searchTextDestination = coordinate.name ?? ""
                self.region.center = coordinate.placemark.coordinate
                self.selectedDetent = .medium
                self.findAllPossibleRoutes()
            }
            self.searchResults.removeAll()
        }
    }
}
