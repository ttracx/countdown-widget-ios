import SwiftUI
import WidgetKit

struct CountdownEvent: Identifiable, Codable {
    let id = UUID()
    var name: String
    var date: Date
}

class CountdownViewModel: ObservableObject {
    @Published var events: [CountdownEvent] = []
    @Published var isPro = false
    
    private let defaults = UserDefaults(suiteName: "group.com.yourname.countdownwidget")
    private let eventsKey = "countdownEvents"
    private let proKey = "isProUser"
    private let freeLimit = 2
    
    init() {
        loadEvents()
        isPro = defaults?.bool(forKey: proKey) ?? false
    }
    
    func canAddMore() -> Bool {
        return isPro || events.count < freeLimit
    }
    
    func addEvent(name: String, date: Date) {
        let event = CountdownEvent(name: name, date: date)
        events.append(event)
        saveEvents()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func deleteEvent(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
        saveEvents()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            defaults?.set(encoded, forKey: eventsKey)
        }
    }
    
    private func loadEvents() {
        if let data = defaults?.data(forKey: eventsKey),
           let decoded = try? JSONDecoder().decode([CountdownEvent].self, from: data) {
            events = decoded
        }
    }
    
    func purchasePro() {
        isPro = true
        defaults?.set(true, forKey: proKey)
    }
}
