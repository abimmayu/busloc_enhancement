struct CompleteRouteOption {
    let route: BusRouteOption
    let walkingTimeToStart: TimeInterval
    let walkingTimeToEnd: TimeInterval
    
    var totalDuration: TimeInterval {
        walkingTimeToStart + route.duration + walkingTimeToEnd
    }
}