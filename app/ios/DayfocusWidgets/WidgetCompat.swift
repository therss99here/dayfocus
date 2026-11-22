import SwiftUI
import WidgetKit

extension View {
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return AnyView(self.containerBackground(for: .widget) {
                Color(UIColor.systemBackground)
            })
        } else {
            return AnyView(self.padding().background(Color(UIColor.systemBackground)))
        }
    }
}
