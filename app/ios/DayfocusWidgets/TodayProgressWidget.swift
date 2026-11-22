import SwiftUI
import WidgetKit

struct TodayProgressEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct TodayProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayProgressEntry {
        TodayProgressEntry(date: Date(), data: .load())
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayProgressEntry) -> Void) {
        completion(TodayProgressEntry(date: Date(), data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayProgressEntry>) -> Void) {
        let entry = TodayProgressEntry(date: Date(), data: .load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct TodayProgressWidgetView: View {
    let entry: TodayProgressEntry

    private var accent: Color { Color(red: 0.96, green: 0.63, blue: 0.14) }
    private var completed: Color { Color(red: 0.37, green: 0.62, blue: 0.44) }

    var body: some View {
        if entry.data.hasData {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: entry.data.priorityProgress)
                        .stroke(
                            entry.data.priorityProgress >= 1.0 ? completed : accent,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 0) {
                        Text("\(entry.data.completedPriorities)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("of \(entry.data.totalPriorities)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 72, height: 72)

                if entry.data.totalBlocks > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("\(entry.data.completedBlocks)/\(entry.data.totalBlocks) blocks")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .widgetBackground()
            .widgetURL(URL(string: "dayfocus://"))
        } else {
            VStack(spacing: 8) {
                Image(systemName: "sun.max")
                    .font(.system(size: 28))
                    .foregroundColor(accent)
                Text("Plan your day")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .widgetBackground()
            .widgetURL(URL(string: "dayfocus://"))
        }
    }
}

struct TodayProgressWidget: Widget {
    let kind = "TodayProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProgressProvider()) { entry in
            TodayProgressWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Progress")
        .description("See how many priorities you've completed today.")
        .supportedFamilies([.systemSmall])
    }
}
