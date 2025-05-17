//
//  BusSchedule.swift
//  busloc
//
//  Created by Abim on 15/05/25.
//

import Foundation

struct BusSchedule: Codable, Hashable {
    let session: Int
    let busNumber: Int
    let stopName: String
    let arrivalTime: Date
    
    enum CodingKeys: String, CodingKey {
        case session
        case busNumber = "bus_number"
        case stopName = "stop_name"
        case arrivalTime = "arrival_time"
    }
}

let dateFormatter = ISO8601DateFormatter()

let schedules: [BusSchedule] = ScheduleLoader.load()

