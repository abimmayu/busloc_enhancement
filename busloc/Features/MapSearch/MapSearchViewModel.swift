//
//  MapSearchViewModel.swift
//  busloc
//
//  Created by Abim on 15/05/25.
//

import Foundation
import MapKit
import SwiftUI

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
    @Published var selectedDetent: PresentationDetent = .fraction(0.2)
    @Published var routePolylines: [MKPolyline] = []
    @Published var selectedRoute: CompleteRouteOption? {
        didSet {
            updatePolylineForSelectedRoute()
        }
    }
    var busStopsForSelectedRoute: [BusStop] {
        guard let selectedRoute = selectedRoute else { return [] }
        let stopNames = Set(selectedRoute.route.route.map { $0.stopName.lowercased() })
        return allStops.filter { stopNames.contains($0.name.lowercased()) }
    }
    
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
    
    init() {
        self.allBuses = buses
        self.allStops = busStops
        self.allSchedule = schedules
    }
    
    func setUserLocationAsStart(_ coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        self.searchTextStartCoordinate = mapItem
        self.searchTextStart = mapItem.name ?? ""
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
    
    func findFastestRoutes() {
        guard
            let userCoordinate = searchTextStartCoordinate?.placemark.coordinate,
            let destinationCoordinate = searchTextDestinationCoordinate?.placemark.coordinate,
            let startStop = nearestStop(to: userCoordinate, stops: allStops),
            let endStop = nearestStop(to: destinationCoordinate, stops: allStops)
        else {
            print("❌ Lokasi awal/tujuan tidak valid")
            return
        }

        let startCL = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let endCL = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        
        let startStopCL = CLLocation(latitude: startStop.latitude, longitude: startStop.longitude)
        let endStopCL = CLLocation(latitude: endStop.latitude, longitude: endStop.longitude)

        let walkingSpeed: Double = 1.4 // meter per second
        let walkStartTime = startCL.distance(from: startStopCL) / walkingSpeed
        let walkEndTime = endStopCL.distance(from: endCL) / walkingSpeed

        let grouped = Dictionary(grouping: allSchedule) { BusKey(session: $0.session, busNumber: $0.busNumber) }

        var options: [CompleteRouteOption] = []

        for (key, list) in grouped {
            let session = key.session
            let busNumber = key.busNumber
            let sorted = list.sorted { $0.arrivalTime < $1.arrivalTime }

            guard
                let startIdx = sorted.firstIndex(where: { $0.stopName.lowercased() == startStop.name.lowercased() }),
                let endIdx = sorted.firstIndex(where: { $0.stopName.lowercased() == endStop.name.lowercased() }),
                startIdx < endIdx
            else { continue }

            let slicedRoute = Array(sorted[startIdx...endIdx])
//            let routeDuration = slicedRoute.last!.arrivalTime.timeIntervalSince(slicedRoute.first!.arrivalTime)
            
            let walkStartTimeInMinutes = walkStartTime / 60
            let walkEndTimeInMinutes = walkEndTime / 60

            let routeDurationInMinutes = Int(ceil(
                slicedRoute.last!.arrivalTime.timeIntervalSince(slicedRoute.first!.arrivalTime) / 60
            ))


            let routeOption = BusRouteOption(
                session: session,
                busNumber: busNumber,
                route: slicedRoute,
                duration: routeDurationInMinutes
            )

            let completeOption = CompleteRouteOption(
                route: routeOption,
                walkingTimeToStart: walkStartTimeInMinutes,
                walkingTimeToEnd: walkEndTimeInMinutes
            )

            options.append(completeOption)
        }

        self.searchRouteResult = options.sorted(by: { $0.totalDuration < $1.totalDuration })
    }
    
    func updatePolylineForSelectedRoute() {
        DispatchQueue.main.async {
            self.selectedDetent = .fraction(0.3)
        }
        guard let selectedRoute = selectedRoute else {
            self.routePolylines = []
            return
        }

        let coordinates: [CLLocationCoordinate2D] = selectedRoute.route.route.compactMap { schedule in
            if let stop = allStops.first(where: { $0.name.lowercased() == schedule.stopName.lowercased() }) {
                return CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
            } else {
                return nil
            }
        }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        self.routePolylines = [polyline]

        if let first = coordinates.first {
            DispatchQueue.main.async {
                self.region.center = first
            }
        }
    }



    func performSearch(isStartPoint: Bool = true) {
        let request = MKLocalSearch.Request()
        isStartPointSearch = isStartPoint
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
            if(self.isStartPointSearch == true) {
                self.searchTextStartCoordinate = coordinate
                self.searchTextStart = coordinate.name ?? ""
                self.region.center = coordinate.placemark.coordinate
                self.selectedDetent = .fraction(0.2)
            } else {
                self.searchTextDestinationCoordinate = coordinate
                self.searchTextDestination = coordinate.name ?? ""
                self.region.center = coordinate.placemark.coordinate
                self.selectedDetent = .medium
                self.findFastestRoutes()
            }
            
            self.searchResults.removeAll()
        }
    }
}
