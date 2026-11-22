import Foundation

struct WidgetPriority: Codable {
    let title: String
    let isDone: Bool
    let sortOrder: Int
}

struct WidgetData {
    let completedPriorities: Int
    let totalPriorities: Int
    let priorities: [WidgetPriority]
    let nextBlockTitle: String?
    let nextBlockTime: String?
    let nextBlockStatus: String?
    let completedBlocks: Int
    let totalBlocks: Int
    let lastUpdated: Date?

    var priorityProgress: Double {
        guard totalPriorities > 0 else { return 0 }
        return Double(completedPriorities) / Double(totalPriorities)
    }

    var hasData: Bool {
        totalPriorities > 0 || totalBlocks > 0
    }

    static func load() -> WidgetData {
        let defaults = UserDefaults(suiteName: "group.app.dayfocus.ios.widgets")

        var priorities: [WidgetPriority] = []
        if let jsonString = defaults?.string(forKey: "priorities_json"),
           let data = jsonString.data(using: .utf8) {
            priorities = (try? JSONDecoder().decode([WidgetPriority].self, from: data)) ?? []
        }
        priorities.sort { $0.sortOrder < $1.sortOrder }

        var lastUpdated: Date?
        if let isoString = defaults?.string(forKey: "last_updated") {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            lastUpdated = formatter.date(from: isoString)
        }

        return WidgetData(
            completedPriorities: defaults?.integer(forKey: "completed_priorities") ?? 0,
            totalPriorities: defaults?.integer(forKey: "total_priorities") ?? 0,
            priorities: priorities,
            nextBlockTitle: defaults?.string(forKey: "next_block_title"),
            nextBlockTime: defaults?.string(forKey: "next_block_time"),
            nextBlockStatus: defaults?.string(forKey: "next_block_status"),
            completedBlocks: defaults?.integer(forKey: "completed_blocks") ?? 0,
            totalBlocks: defaults?.integer(forKey: "total_blocks") ?? 0,
            lastUpdated: lastUpdated
        )
    }
}
