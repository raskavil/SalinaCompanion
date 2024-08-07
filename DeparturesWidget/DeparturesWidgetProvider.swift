import WidgetKit
import Models
import Networking

struct DeparturesWidgetProvider: AppIntentTimelineProvider {
    
    typealias Configuration = DeparturesWidgetConfigurationIntent
    
    static var dynamicProvider: DynamicModelsManager {
        .init(stopsAndAliasesProvider: Configuration.staticProvider)
    }

    func placeholder(in context: Context) -> DeparturesModel {
        .init(date: Date(), configuration: Configuration(), post: nil)
    }

    func snapshot(for configuration: Configuration, in context: Context) async -> DeparturesModel {
        guard let post = configuration.post else { return .init(date: .now, configuration: configuration, post: nil) }
        
        if let departures = try? await Self.dynamicProvider.departures(for: post.stopId),
           let loadedPost = departures.first(where: { $0.name == post.postName }) {
            return .init(
                date: .now,
                configuration: configuration,
                post: loadedPost
            )
        } else {
            return .init(
                date: .now,
                configuration: configuration,
                post: .init(
                    name: post.postName,
                    id: post.postId,
                    stopId: post.stopId,
                    departures: nil,
                    lines: nil
                )
            )
        }
    }
    
    func timeline(for configuration: Configuration, in context: Context) async -> Timeline<DeparturesModel> {
        let entry: DeparturesModel
        if let post = configuration.post {
            if let departures = try? await Self.dynamicProvider.departures(for: post.stopId),
               let loadedPost = departures.first(where: { $0.name == post.postName }) {
                entry = .init(
                    date: .now,
                    configuration: configuration,
                    post: loadedPost
                )
            } else {
                entry = .init(
                    date: .now,
                    configuration: configuration,
                    post: .init(
                        name: post.postName,
                        id: post.postId,
                        stopId: post.stopId,
                        departures: nil,
                        lines: nil
                    )
                )
            }
        } else {
            entry = .init(date: .now, configuration: configuration, post: nil)
        }

        return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60)))
    }
}
