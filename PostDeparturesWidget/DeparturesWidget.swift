import WidgetKit
import SwiftUI
import Models
import Networking
import SupportPackageViews

struct DeparturesWidget: Widget {

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "DeparturesWidget",
            intent: DeparturesWidgetConfigurationIntent.self,
            provider: DeparturesWidgetProvider()
        ) { entry in
            DeparturesWidgetView(entry: entry)
                .containerBackground(.widgetBackground, for: .widget)
                .widgetURL(entry.configuration.post.flatMap { URL(string: "widget://\($0.stopId)") })
        }
        .supportedFamilies([.systemMedium])
    }
}

struct DeparturesModel: TimelineEntry {
    let date: Date
    let configuration: DeparturesWidgetConfigurationIntent
    let post: Post?
    
    var model: Post {
        post ?? .init(
            name: .init(localized: "stop.choose"),
            id: 0,
            stopId: 0,
            departures: Post.mock.departures,
            lines: nil
        )
    }
    
    var stopName: String {
        configuration.post?.stopName ?? .init(localized: "stop.imaginary")
    }
}

struct DeparturesWidgetView: View {
    
    private static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var entry: DeparturesModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            
            SwiftUI.Text("updated.\(Self.formatter.string(from: entry.date))")
                .font(.system(size: 10))
                .frame(maxWidth: .infinity)

            HStack {
                Image(.tramIcon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 1)
                VStack(alignment: .leading, spacing: 4) {
                    SwiftUI.Text(entry.stopName)
                        .font(.system(size: 14, weight: .semibold))
                    SwiftUI.Text(entry.model.name)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
            }
            
            if let departures = entry.model.departures, departures.isEmpty == false {
                ForEach(Array(departures.first(4).enumerated()), id: \.offset) { departure($1) }
            } else {
                SwiftUI.Text("departures.not_found")
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private func departure(_ departure: Departure) -> some View {
        HStack {
            HStack(spacing: 4) {
                Icon(departure.alias.vehicleType.icon, size: .tiny)
                SwiftUI.Text(departure.alias.lineName)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(departure.alias.contentColor)
            .padding(4)
            .frame(minWidth: 35, minHeight: 16, alignment: .center)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(departure.alias.backgroundColor)
            }
            .frame(minWidth: 45, minHeight: 20, alignment: .leading)
            
            SwiftUI.Text(departure.finalStopName)
                .font(.system(size: 14, weight: .medium))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(.content)
            Spacer()
            
            SwiftUI.Text(departure.time)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.content)
        }
    }
}

#Preview(as: .systemMedium) {
    DeparturesWidget()
} timeline: {
    DeparturesModel(date: .now, configuration: .init(), post: nil)
}

extension Array {
    
    func first(_ k: Int) -> ArraySlice<Element> {
        guard (count - k) >= 0 else { return dropLast(0) }
        return dropLast(count - k)
    }
}
