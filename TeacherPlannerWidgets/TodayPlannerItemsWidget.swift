import WidgetKit
import SwiftUI

struct TodayPlannerItemsProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayPlannerItemsEntry {
        TodayPlannerItemsEntry(date: Date(), itemsCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayPlannerItemsEntry) -> Void) {
        let entry = TodayPlannerItemsEntry(date: Date(), itemsCount: SharedWidgetData.readFromAppGroup()?.itemsCount ?? 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayPlannerItemsEntry>) -> Void) {
        let count = SharedWidgetData.readFromAppGroup()?.itemsCount ?? 0
        
        let entry = TodayPlannerItemsEntry(date: Date(), itemsCount: count)
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct TodayPlannerItemsEntry: TimelineEntry {
    let date: Date
    let itemsCount: Int
}

struct TodayPlannerItemsWidgetEntryView: View {
    var entry: TodayPlannerItemsProvider.Entry

    var body: some View {
        VStack {
            Text("Yapılacaklar")
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)
            
            Text("\(entry.itemsCount)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.accentColor)
            
            Text("Görev Bekliyor")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct TodayPlannerItemsWidget: Widget {
    let kind: String = "TodayPlannerItemsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayPlannerItemsProvider()) { entry in
            TodayPlannerItemsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Bugün Yapılacaklar")
        .description("Bugün tamamlamanız gereken görev sayısını gösterir.")
        .supportedFamilies([.systemSmall])
    }
}
