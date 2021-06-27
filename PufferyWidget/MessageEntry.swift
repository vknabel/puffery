import PufferyKit
import WidgetKit

struct MessageEntry: TimelineEntry {
    let message: Message?
    let configuration: ChannelWidgetsIntent

    var date: Date {
        Date()
    }
}
