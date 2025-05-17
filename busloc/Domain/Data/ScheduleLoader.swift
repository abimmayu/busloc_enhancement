class ScheduleLoader {
    static func load() -> [BusSchedule] {
        guard let url = Bundle.main.url(forResource: "Schedule", withExtension: "json") else {
            print("❌ File not found")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Format waktu sesuai dengan JSON
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(formatter)

            let schedules = try decoder.decode([BusSchedule].self, from: data)
            return schedules
        } catch {
            print("❌ Error decoding: \(error)")
            return []
        }
    }
}
