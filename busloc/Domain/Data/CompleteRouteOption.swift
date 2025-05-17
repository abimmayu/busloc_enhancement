//
//  CompleteRouteOption.swift
//  busloc
//
//  Created by Abim on 16/05/25.
//
import Foundation

struct CompleteRouteOption: Hashable {
    let route: BusRouteOption
    let walkingTimeToStart: TimeInterval
    let walkingTimeToEnd: TimeInterval
    
    var numberOfStops: Int {
        route.route.count
    }
    var stopNames: [String] {
        route.route.map { $0.stopName }
    }
    var totalDuration: Int {
        Int(ceil(walkingTimeToStart + Double(route.duration) + walkingTimeToEnd))
    }
}
