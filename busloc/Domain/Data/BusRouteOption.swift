//
//  BusRouteOption.swift
//  busloc
//
//  Created by Abim on 16/05/25.
//
import Foundation

struct BusRouteOption: Hashable {
    let session: Int
    let busNumber: Int
    let route: [BusSchedule]
    let duration: Int
}
