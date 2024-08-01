import SwiftUI
import Combine
import MapKit
import Models
import SupportPackageViews

struct VehiclesMap: View {
    
    @StateObject private var model: Model
    @Environment(\.dynamicDataProvider) private var dynamicDataProvider
    @Environment(\.permissionsProvider) private var permissionsProvider
    @Environment(\.staticDataProvider) private var staticDataProvider
    
    @State private var blockVehicleSelection = false
    private let mapPosition: PassthroughSubject<MKMapRect, Never>
    
    var body: some View {
        content
            .alert(
                Text("error.something_went_wrong"),
                isPresented: model.alertPresentedBiding,
                actions: {
                    Button("error.ok", action: { model.numberOfErrors = 0 })
                }
            )
            .onAppear {
                model.vehiclesProvider = dynamicDataProvider
                model.filtersProvider = staticDataProvider
                model.subscribe(to: permissionsProvider)
            }
            .sheet(isPresented: $model.filtersPresented) {
                MapFilter(
                    vehicles: model.filtersData,
                    filteredAliases: $model.filteredLines,
                    close: { model.filtersPresented.toggle() }
                )
            }
    }
    
    @ViewBuilder private var content: some View {
        Map(position: $model.position) {
            UserAnnotation()
            ForEach(model.displayedVehicles, id: \.id) { vehicle in
                Annotation(
                    coordinate: vehicle.position,
                    content: { 
                        annotation(for: vehicle)
                            .if(model.displayedVehicle != nil) {
                                $0.opacity(vehicle.id == model.displayedVehicle?.vehicle.id ? 1 : 0.5)
                            }
                    },
                    label: {
                        if model.displayedVehicles.count <= 30 || vehicle.id == model.displayedVehicle?.vehicle.id {
                            Text(vehicle.name)
                        }
                    }
                )
            }
            if case .loaded(let vehicleRoute) = model.displayedVehicle {
                MapPolyline(coordinates: vehicleRoute.stops.filter(\.isServed).flatMap(\.path))
                    .stroke(vehicleRoute.vehicle.alias.backgroundColor.opacity(0.5), style: .init(
                        lineWidth: 5,
                        lineCap: .round,
                        lineJoin: .round
                    ))
                MapPolyline(coordinates: vehicleRoute.stops.filter { $0.isServed == false }.flatMap(\.path))
                    .stroke(vehicleRoute.vehicle.alias.backgroundColor, style: .init(
                        lineWidth: 5,
                        lineCap: .round,
                        lineJoin: .round
                    ))
            }
        }
        .onMapCameraChange { context in
            mapPosition.send(context.rect)
        }
        .overlay(alignment: .bottomLeading) {
            mapButtons
        }
        .overlay {
            if model.displayedVehicle != nil {
                GeometryReader { proxy in
                    VehicleDetail(
                        model: $model.displayedVehicle,
                        close: {
                            blockVehicleSelection = true
                            withAnimation(.linear(duration: 0.25)) {
                                model.displayedVehicle = nil
                            } completion: {
                                blockVehicleSelection = false
                            }
                        }
                    )
                        .background {
                            UnevenRoundedRectangle(cornerRadii: .init(topLeading: 12, topTrailing: 12))
                                .foregroundStyle(.white)
                        }
                        .frame(height: proxy.size.height / 2)
                        .offset(y: proxy.size.height / 2)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .overlay(alignment: .topTrailing) {
            if model.loading {
                HStack(spacing: 4) {
                    ProgressView()
                    SwiftUI.Text("loading")
                        .bold()
                        .font(.system(size: 13))
                }
                .padding(8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 8)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                model.focusUserLocation()
            }
        }
    }
    
    private var locationIcon: Icon.Content {
        guard permissionsProvider.features[.location] == .allowed else { return .system("location.slash") }
        return .system(model.position.followsUserLocation ? "location.fill" : "location")
    }
    
    private var mapButtons: some View {
        VStack(spacing: 10) {
            Button(action: {
                model.filtersPresented.toggle()
            }) {
                Icon(.system(
                    model.filteredLines.isEmpty
                    ? "slider.horizontal.below.rectangle"
                    : "slider.horizontal.below.square.filled.and.square"
                ))
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
            Button(action: {
                if permissionsProvider.features[.location] == .allowed {
                    model.focusUserLocation()
                } else {
                    permissionsProvider.requestAuthorization(.location)
                }
            }) {
                Icon(locationIcon)
                    .foregroundStyle(permissionsProvider.features[.location] == .allowed
                                     ? Color(uiColor: UIColor.tintColor)
                                     : .secondary)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.bottom, 28)
        .padding(.leading, 10)
    }
    
    @ViewBuilder private func annotation(for vehicle: Vehicle) -> some View {
        if model.displayedVehicles.count > 30 && vehicle.id != model.displayedVehicle?.vehicle.id {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundStyle(vehicle.alias.backgroundColor)
        } else {
            VehicleMarker(vehicle: vehicle)
                .onTapGesture {
                    if blockVehicleSelection == false {
                        withAnimation(.linear(duration: 0.25)) {
                            model.displayedVehicle = .loading(vehicle)
                        }
                    }
                }
        }
    }
    
    init() {
        let publisher = PassthroughSubject<MKMapRect, Never>()
        mapPosition = publisher
        _model = .init(wrappedValue: .init(mapPosition: publisher.eraseToAnyPublisher()))
    }
    
}

struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .init(x: rect.minX, y: rect.maxY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
        path.addLine(to: .init(x: rect.midX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

import Networking

struct MapPreviews: PreviewProvider {
    
    static var stopsAndAliasesProvider: StaticModelsProviding = StaticModelsManager()
    
    static var previews: some View {
        VehiclesMap()
            .task {
                _ = await stopsAndAliasesProvider.isUpToDate
            }
            .environment(\.dynamicDataProvider, DynamicModelsManager(stopsAndAliasesProvider: stopsAndAliasesProvider))
    }
}
