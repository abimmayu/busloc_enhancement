//
//  Bus.swift
//  busloc
//
//  Created by Abim on 15/05/25.
//


import Foundation

struct TheBus: Identifiable, Codable {
    let id: UUID
    let busNumber: Int
    let busName: String
    let licensePlate: String
    let busColor: String

    enum CodingKeys: String, CodingKey {
        case id = "bus_id"
        case busNumber = "bus_number"
        case busName = "bus_name"
        case licensePlate = "license_plate"
        case busColor = "bus_color"
    }
}

let buses: [TheBus] = [
    TheBus(id: UUID(uuidString: "0e38f0d0-72a6-47aa-afcc-f233c25697f2")!, busNumber: 1, busName: "Intermoda - Sektor 1.3", licensePlate: "B7966PAA", busColor: "yellow"),
    TheBus(id: UUID(uuidString: "de5b3880-2115-4a5a-80ee-212d99427b85")!, busNumber: 2, busName: "Intermoda - Sektor 1.3", licensePlate: "B7666PAA", busColor: "red"),
    TheBus(id: UUID(uuidString: "cd3ec418-e4ad-467d-a75d-32f233af6176")!, busNumber: 3, busName: "Greenwich - Sektor 1.3", licensePlate: "B7266JF", busColor: "green"),
    TheBus(id: UUID(uuidString: "f3485c68-5457-46ff-be63-bb11b72e2714")!, busNumber: 4, busName: "Greenwich - Sektor 1.3", licensePlate: "B7466PAA", busColor: "orange"),
    TheBus(id: UUID(uuidString: "d1237dfe-9f29-4400-a621-279dbebb059b")!, busNumber: 5, busName: "De Park 1", licensePlate: "B7366PAA", busColor: "mint"),
    TheBus(id: UUID(uuidString: "0f045548-66bc-4cde-88e5-b41c00568083")!, busNumber: 6, busName: "De Park 2", licensePlate: "B7366JE", busColor: "gray"),
    TheBus(id: UUID(uuidString: "5f7efe8b-3659-4113-a66f-d12e90a566c3")!, busNumber: 7, busName: "The Breeze", licensePlate: "B7166PAA", busColor: "indigo"),
    TheBus(id: UUID(uuidString: "359b17f8-17ec-4fe5-b238-195e7e79da7d")!, busNumber: 8, busName: "The Breeze", licensePlate: "B7866PAA", busColor: "cyan"),
    TheBus(id: UUID(uuidString: "ff753625-d031-472b-9cb3-4cedaede7205")!, busNumber: 9, busName: "Vanya", licensePlate: "B7766PAA", busColor: "purple"),
    TheBus(id: UUID(uuidString: "a3e27709-2d85-4bd6-8dc2-fb4e018f700c")!, busNumber: 10, busName: "Electric Bus", licensePlate: "B7002PGX", busColor: "pink")
]
