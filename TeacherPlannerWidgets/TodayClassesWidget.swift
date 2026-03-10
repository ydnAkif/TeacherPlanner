import SwiftUI
import WidgetKit

struct TodayClassesProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayClassesEntry {
        TodayClassesEntry(date: Date(), sessions: [
            SharedWidgetSession(title: "Fen Bilimleri", symbolName: "flask.fill", colorHex: "#ff9500", startTime: Date(), endTime: Date().addingTimeInterval(3600))
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayClassesEntry) -> Void) {
        let entry = TodayClassesEntry(date: Date(), sessions: SharedWidgetData.readFromAppGroup()?.todaySessions ?? [])
        completion(entry)
    }

    func getTimeline(
        in context: Context, completion: @escaping (Timeline<TodayClassesEntry>) -> Void
    ) {
        let entry = TodayClassesEntry(date: Date(), sessions: SharedWidgetData.readFromAppGroup()?.todaySessions ?? [])
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct TodayClassesEntry: TimelineEntry {
    let date: Date
    let sessions: [SharedWidgetSession]
}

struct TodayClassesWidgetEntryView: View {
    var entry: TodayClassesProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Bugünün Dersleri")
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)

            if entry.sessions.isEmpty {
                Text("Bugün dersiniz bulunmuyor.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                ForEach(entry.sessions.prefix(4)) { session in
                    HStack {
                        Image(systemName: session.symbolName)
                            .foregroundColor(Color.accentColor) // Since Color(hex) is unavailable

                        Text(session.title)
                            .font(.caption)
                            .lineLimit(1)

                        Spacer()

                        Text(session.startTime, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct TodayClassesWidget: Widget {
    let kind: String = "TodayClassesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayClassesProvider()) { entry in
            TodayClassesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bugünün Dersleri")
        .description("Bugünkü ders programınızı liste halinde gösterir.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    TodayClassesWidget()
} timeline: {
    TodayClassesEntry(date: .now, sessions: [
        SharedWidgetSession(title: "Fen Bilimleri", symbolName: "flask.fill", colorHex: "#ff9500", startTime: Date(), endTime: Date().addingTimeInterval(3600)),
        SharedWidgetSession(title: "Matematik", symbolName: "function", colorHex: "#007aff", startTime: Date().addingTimeInterval(4000), endTime: Date().addingTimeInterval(7600))
    ])
}
