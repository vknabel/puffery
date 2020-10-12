import PufferyKit
import PufferyUI
import Intents
import SwiftUI
import WidgetKit

@main
struct PufferyWidget: Widget {
    let kind: String = "PufferyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ChannelWidgetsIntent.self, provider: Provider()) { entry in
            PufferyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("News")
        .description("Display latest news.")
    }
}
