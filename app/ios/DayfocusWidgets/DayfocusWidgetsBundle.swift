import SwiftUI
import WidgetKit

@main
struct DayfocusWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayProgressWidget()
        UpNextWidget()
        PrioritiesWidget()
    }
}
