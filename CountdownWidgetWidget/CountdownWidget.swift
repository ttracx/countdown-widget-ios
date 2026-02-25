import WidgetKit
import SwiftUI

struct CountdownEvent: Identifiable, Codable {
    let id = UUID()
    var name: String
    var date: Date
}

struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), event: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> ()) {
        let event = loadEvents().first
        let entry = CountdownEntry(date: Date(), event: event)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let events = loadEvents()
        let currentDate = Date()
        
        var entries: [CountdownEntry] = []
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = CountdownEntry(date: entryDate, event: events.first)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadEvents() -> [CountdownEvent] {
        let defaults = UserDefaults(suiteName: "group.com.yourname.countdownwidget")
        guard let data = defaults?.data(forKey: "countdownEvents"),
              let events = try? JSONDecoder().decode([CountdownEvent].self, from: data) else {
            return []
        }
        return events.sorted { $0.date < $1.date }
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let event: CountdownEvent?
}

struct CountdownWidgetEntryView : View {
    var entry: CountdownProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var daysRemaining: Int {
        guard let event = entry.event else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: event.date).day ?? 0
    }
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.blue.gradient)
            
            if let event = entry.event {
                VStack(spacing: 4) {
                    Text(event.name)
                        .font(family == .systemSmall ? .caption : .headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundColor(.white)
                    
                    Text("\(daysRemaining)")
                        .font(.system(size: family == .systemSmall ? 36 : 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("days left")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Add a countdown")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

@main
struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Event Countdown")
        .description("Shows days until your next event")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
