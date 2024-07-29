import SwiftUI
import Models
import SupportPackageViews

struct MapFilter: View {
    
    let vehicles: [VehicleType: [Alias]]?
    @Binding var filteredAliases: Set<Int>
    let close: () -> Void

    @State private var impactFeedback = false
    
    private var types: [VehicleType] {
        [
            vehicles?[.tram]?.isEmpty == false ? .tram : nil,
            vehicles?[.trolleybus]?.isEmpty == false ? .trolleybus : nil,
            vehicles?[.train]?.isEmpty == false ? .train : nil,
            vehicles?[.boat]?.isEmpty == false ? .boat : nil,
            vehicles?[.bus]?.isEmpty == false ? .bus : nil,
        ]
        .compactMap { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                SwiftUI.Text("map.filter")
                    .font(.title3)
                    .bold()
                Spacer()
                closeButton
            }
            if let vehicles {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(types) { vehicleType in
                            HStack {
                                Icon(vehicleType.icon)
                                SwiftUI.Text(vehicleType.title)
                                    .font(.headline)
                                    .bold()
                                Spacer()
                                if Set(vehicles[vehicleType]?.map(\.id) ?? []).intersection(filteredAliases).isEmpty {
                                    Button(action: {
                                        impactFeedback.toggle()
                                        withAnimation {
                                            filteredAliases = filteredAliases.union(Set(vehicles[vehicleType]?.map(\.id) ?? []))
                                        }
                                        
                                    }) {
                                        SwiftUI.Text("map.filter.unselect_all")
                                            .font(.system(size: 14))
                                            .bold()
                                    }
                                } else {
                                    Button(action: {
                                        impactFeedback.toggle()
                                        withAnimation {
                                            filteredAliases = filteredAliases.subtracting(Set(vehicles[vehicleType]?.map(\.id) ?? []))
                                        }
                                    }) {
                                        SwiftUI.Text("map.filter.select_all")
                                            .font(.system(size: 14))
                                            .bold()
                                    }
                                }
                            }
                            VCollection {
                                ForEach((vehicles[vehicleType] ?? []).sorted { $0.id < $1.id }, id: \.id) { alias in
                                    lineBadge(alias)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            } else {
                
            }
            Spacer()
        }
        .sensoryFeedback(.impact(), trigger: impactFeedback)
        .padding(.top, 14)
        .padding(.horizontal, 16)
    }
    
    private func lineBadge(_ alias: Alias) -> some View {
        SwiftUI.Text(alias.lineName)
            .bold()
            .foregroundStyle(alias.contentColor)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .frame(minWidth: 40)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(alias.backgroundColor)
            }
            .onTapGesture(count: 1) {
                impactFeedback.toggle()
                withAnimation {
                    filteredAliases.toggleMembership(of: alias.id)
                }
            }
            .opacity(filteredAliases.contains(alias.id) ? 0.5 : 1)
    }
    
    private var closeButton: some View {
        Button(action: close) {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color(white: 0.85))
                .overlay {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .bold()
                        .foregroundStyle(Color(white: 0.45))
                }
        }
    }
}

extension VehicleType {
    
    var title: String {
        return switch self {
        case .boat: .init(localized: "vehicle.boat")
        case .tram: .init(localized: "vehicle.tram")
        case .bus: .init(localized: "vehicle.bus")
        case .trolleybus: .init(localized: "vehicle.trolleybus")
        case .train: .init(localized: "vehicle.train")
        }
    }
}

import Networking

struct MapFilterPreviews: PreviewProvider {
    
    static var stopsAndAliasesProvider: StaticModelsProviding = StaticModelsManager()
    
    static var previews: some View {
        Color.red.sheet(isPresented: .constant(true)) {
            MapFilter(vehicles: [:], filteredAliases: .constant([]), close: {})
                .environment(\.staticDataProvider, stopsAndAliasesProvider)
                .environment(\.dynamicDataProvider, DynamicModelsManager(stopsAndAliasesProvider: stopsAndAliasesProvider))
                .presentationDetents([.medium])
        }
    }
}

extension Set {
    
    mutating func toggleMembership(of element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
    
    func removing(_ member: Element) -> Self {
        var mutableSelf = self
        mutableSelf.remove(member)
        return mutableSelf
    }
}
