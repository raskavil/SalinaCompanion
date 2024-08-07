import WidgetKit
import AppIntents
import Models
import Networking

struct DeparturesWidgetConfigurationIntent: WidgetConfigurationIntent {
    
    static let staticProvider: StaticModelsManager = .init()
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Zastávka", optionsProvider: PostsProvider())
    var postRepresentation: String?
    
    var post: PostRepresentation? {
        postRepresentation.flatMap(PostRepresentation.init(json:))
    }
    
    struct PostRepresentation: Codable {

        let stopName: String
        let stopId: Int
        let postName: String
        let postId: Int
        
        var json: String? {
            try? String(data: JSONEncoder().encode(self), encoding: .utf8)
        }
        
        init?(json: String) {
            guard
                let data = json.data(using: .utf8),
                let value = try? JSONDecoder().decode(Self.self, from: data)
            else { return nil }
            self = value
        }
        
        init(stopName: String, stopId: Int, postName: String, postId: Int) {
            self.stopName = stopName
            self.stopId = stopId
            self.postName = postName
            self.postId = postId
        }
    }
    
    struct PostsProvider: DynamicOptionsProvider {
        
        func results() async throws -> ItemCollection<String> {
            if await DeparturesWidgetConfigurationIntent.staticProvider.isUpToDate {
                return .init(
                    sections: DeparturesWidgetConfigurationIntent.staticProvider.stops
                        .filter { $0.zone == 100 || $0.zone == 101 }
                        .sorted { $0.name < $1.name }
                        .compactMap { stop in
                            DeparturesWidgetConfigurationIntent.staticProvider.posts[stop.id].map { posts in
                                ItemSection(
                                    .init(stringLiteral: stop.name),
                                    items: posts.map { post in
                                        IntentItem(
                                            PostRepresentation(
                                                stopName: stop.name,
                                                stopId: stop.id,
                                                postName: post.name,
                                                postId: post.id
                                            ).json!,
                                            title: .init(stringLiteral: post.name)
                                        )
                                    }
                                )
                            }
                        }
                )
            } else {
                return .empty
            }
        }
    }
}
