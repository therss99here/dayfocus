import SwiftUI
import WidgetKit

struct PrioritiesEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct PrioritiesProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrioritiesEntry {
        PrioritiesEntry(date: Date(), data: .load())
    }

    func getSnapshot(in context: Context, completion: @escaping (PrioritiesEntry) -> Void) {
        completion(PrioritiesEntry(date: Date(), data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrioritiesEntry>) -> Void) {
        let entry = PrioritiesEntry(date: Date(), data: .load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct PrioritiesWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrioritiesEntry

    private var accent: Color { Color(red: 0.96, green: 0.63, blue: 0.14) }
    private var completed: Color { Color(red: 0.37, green: 0.62, blue: 0.44) }

    private var maxItems: Int {
        family == .systemLarge ? 7 : 3
    }

    var body: some View {
        if entry.data.priorities.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 28))
                    .foregroundColor(accent)
                Text("Tap to add priorities")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .widgetBackground()
            .widgetURL(URL(string: "dayfocus://"))
        } else {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Priorities")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(entry.data.completedPriorities)/\(entry.data.totalPriorities)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(entry.data.priorityProgress >= 1.0 ? completed : accent)
                }
                .padding(.bottom, 8)

                // Priority list
                let items = Array(entry.data.priorities.prefix(maxItems))
                ForEach(Array(items.enumerated()), id: \.offset) { _, priority in
                    HStack(spacing: 8) {
                        Image(systemName: priority.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                            .foregroundColor(priority.isDone ? completed : Color.gray.opacity(0.4))

                        Text(priority.title)
                            .font(.system(size: 14, weight: priority.isDone ? .regular : .medium))
                            .strikethrough(priority.isDone)
                            .foregroundColor(priority.isDone ? .secondary : .primary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, family == .systemLarge ? 5 : 4)
                }

                if entry.data.priorities.count > maxItems {
                    Text("+\(entry.data.priorities.count - maxItems) more")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            .widgetBackground()
            .widgetURL(URL(string: "dayfocus://"))
        }
    }
}

struct PrioritiesWidget: Widget {
    let kind = "PrioritiesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrioritiesProvider()) { entry in
            PrioritiesWidgetView(entry: entry)
        }
        .configurationDisplayName("Priorities")
        .description("Your daily priority checklist at a glance.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
