//
//  StopGraphNode.swift
//  busloc
//
//  Created by Abim on 23/05/25.
//
import GameplayKit

class StopGraphNode: GKGraphNode2D {
    let stopID: String

    init(stop: BusStop) {
        let position = vector_float2(Float(stop.latitude), Float(stop.longitude))
        self.stopID = stop.id
        super.init(point: position)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
}
