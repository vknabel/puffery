import WidgetKit
import PufferyKit

struct MessageEntry: TimelineEntry {
    let message: Message?
    let configuration: ChannelWidgetsIntent

    var date: Date {
        message?.createdAt ?? Date.distantPast
    }
}
