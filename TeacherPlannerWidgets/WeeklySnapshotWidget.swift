import WidgetKit
import SwiftUI

struct WeeklySnapshotProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeeklySnapshotEntry {
        WeeklySnapshotEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WeeklySnapshotEntry) -> Void) {
        let entry = WeeklySnapshotEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeeklySnapshotEntry>) -> Void) {
        let entry = WeeklySnapshotEntry(date: Date())
        let nextUpdateDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct WeeklySnapshotEntry: TimelineEntry {
    let date: Date
}

struct WeeklySnapshotWidgetEntryView: View {
    var entry: WeeklySnapshotProvider.Entry

    var body: some View {
        VStack {
            Text("Haftalık Özet")
                .font(.headline)
            Text("Haftalık ders programı burada gösterilecek")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct WeeklySnapshotWidget: Widget {
    let kind: String = "WeeklySnapshotWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeeklySnapshotProvider()) { entry in
            WeeklySnapshotWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Haftalık Özet")
        .description("Haftalık programınızın kısa bir özetini sunar.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
