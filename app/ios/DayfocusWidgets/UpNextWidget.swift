import SwiftUI
import WidgetKit

struct UpNextEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct UpNextProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpNextEntry {
        UpNextEntry(date: Date(), data: .load())
    }

    func getSnapshot(in context: Context, completion: @escaping (UpNextEntry) -> Void) {
        completion(UpNextEntry(date: Date(), data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UpNextEntry>) -> Void) {
        let entry = UpNextEntry(date: Date(), data: .load())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct UpNextWidgetView: View {
    let entry: UpNextEntry

    private var accent: Color { Color(red: 0.96, green: 0.63, blue: 0.14) }
    private var scheduled: Color { Color(red: 0.29, green: 0.56, blue: 0.85) }
    private var completed: Color { Color(red: 0.37, green: 0.62, blue: 0.44) }
    private var missed: Color { Color(red: 0.88, green: 0.42, blue: 0.42) }

    private func statusColor(for status: String?) -> Color {
        switch status {
        case "inProgress": return accent
        case "completed": return completed
        case "missed": return missed
        default: return scheduled
        }
    }

    private func statusLabel(for status: String?) -> String {
        switch status {
        case "inProgress": return "Now"
        case "completed": return "Done"
        case "missed": return "Missed"
        default: return "Up next"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Left: next block info
            VStack(alignment: .leading, spacing: 4) {
                if let title = entry.data.nextBlockTitle {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(statusColor(for: entry.data.nextBlockStatus))
                            .frame(width: 8, height: 8)
                        Text(statusLabel(for: entry.data.nextBlockStatus))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }

                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(2)

                    if let time = entry.data.nextBlockTime {
                        Text(time)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 22))
                            .foregroundColor(completed)
                        Text(entry.data.totalBlocks > 0 ? "All done!" : "No blocks yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: priority progress
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: entry.data.priorityProgress)
                        .stroke(
                            entry.data.priorityProgress >= 1.0 ? completed : accent,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(entry.data.completedPriorities)/\(entry.data.totalPriorities)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .frame(width: 52, height: 52)
                Text("priorities")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .widgetBackground()
        .widgetURL(URL(string: "dayfocus://"))
    }
}

struct UpNextWidget: Widget {
    let kind = "UpNextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpNextProvider()) { entry in
            UpNextWidgetView(entry: entry)
        }
        .configurationDisplayName("Up Next")
        .description("See your current or upcoming time block.")
        .supportedFamilies([.systemMedium])
    }
}
