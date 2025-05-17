struct BusRouteOption {
    let session: Int
    let busNumber: Int
    let route: [BusSchedule]
    let duration: TimeInterval
}

struct CompleteRouteOption {
    let route: BusRouteOption
    let walkingTimeToStart: TimeInterval
    let walkingTimeToEnd: TimeInterval
    
    var totalDuration: TimeInterval {
        walkingTimeToStart + route.duration + walkingTimeToEnd
    }
}
