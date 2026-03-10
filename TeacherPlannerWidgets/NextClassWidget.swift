import WidgetKit
import SwiftUI

struct NextClassProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextClassEntry {
        NextClassEntry(date: Date(), summary: SharedWidgetData(nextClassTitle: "Matematik", nextClassStart: Date().addingTimeInterval(3600), todaysCount: 4, todaySessions: [], itemsCount: 2))
    }

    func getSnapshot(in context: Context, completion: @escaping (NextClassEntry) -> Void) {
        let entry = NextClassEntry(date: Date(), summary: SharedWidgetData.readFromAppGroup() ?? SharedWidgetData(nextClassTitle: "Örnek Ders", nextClassStart: Date(), todaysCount: 2, todaySessions: [], itemsCount: 1))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextClassEntry>) -> Void) {
        let date = Date()
        let summary = SharedWidgetData.readFromAppGroup() ?? SharedWidgetData(nextClassTitle: "Ders Yok", nextClassStart: date, todaysCount: 0, todaySessions: [], itemsCount: 0)
        
        let entry = NextClassEntry(date: date, summary: summary)
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: date)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct NextClassEntry: TimelineEntry {
    let date: Date
    let summary: SharedWidgetData
}

struct NextClassWidgetEntryView: View {
    var entry: NextClassProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sıradaki Ders")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(entry.summary.nextClassTitle)
                .font(.headline)
            
            if entry.summary.nextClassTitle != "Ders Yok" {
                Text(entry.summary.nextClassStart, style: .time)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.orange)
            }
            
            Spacer()
            
            if entry.summary.todaysCount > 0 {
                Text("Bugün \(entry.summary.todaysCount) ders var")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct NextClassWidget: Widget {
    let kind: String = "NextClassWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextClassProvider()) { entry in
            NextClassWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sıradaki Ders")
        .description("Bugünkü programınızdaki sıradaki dersi gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct TeacherPlannerWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NextClassWidget()
        TodayClassesWidget()
        TodayPlannerItemsWidget()
        WeeklySnapshotWidget()
    }
}

#Preview(as: .systemSmall) {
    NextClassWidget()
} timeline: {
    NextClassEntry(date: .now, summary: SharedWidgetData(nextClassTitle: "6-A Matematik", nextClassStart: Date().addingTimeInterval(3600), todaysCount: 4, todaySessions: [], itemsCount: 2))
}
