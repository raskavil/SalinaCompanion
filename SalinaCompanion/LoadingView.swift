import SwiftUI

struct LoadingView: View {
    
    @Binding var isHidden: Bool
    @State var shown = true
    @State var closed = true
    
    var body: some View {
        content
            .onChange(of: isHidden) {
                if isHidden {
                    withAnimation(.easeIn(duration: 0.3)) {
                        shown = false
                    } completion: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            closed = false
                        }
                    }
                }
            }
    }
    
    @ViewBuilder var content: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(alignment: .trailing, spacing: -18) {
                if shown {
                    Image(.cityBackground)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .move(edge: .trailing))
                            .combined(with: .move(edge: .trailing))
                            .combined(with: .move(edge: .trailing))
                        )
                    
                    Image(.tramBackground)
                        .resizable()
                        .frame(width: 150, height: 85)
                        .transition(
                            .move(edge: .top)
                            .combined(with: .move(edge: .leading))
                            .combined(with: .move(edge: .leading))
                            .combined(with: .move(edge: .leading))
                        )
                }
            }
            if shown {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            VStack(spacing: -49) {
                if closed {
                    Knife(angle: .degrees(-47))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(180))
                        .transition(.move(edge: .top))
                    Knife(angle: .degrees(-47))
                        .foregroundStyle(.white)
                        .transition(.move(edge: .bottom))
                }
            }
            
        }
    }
}

struct Knife: Shape {
    
    let angle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: .init(x: 0, y: rect.height))
        path.addLine(to: .init(x: rect.width, y: rect.height))
        path.addLine(to: .init(x: rect.width, y: tan(angle.degrees) * rect.width))
        path.closeSubpath()
        return path
    }
}

#Preview {
    VehiclesMap()
        .overlay {
            LoadingView(isHidden: .constant(true))
                .ignoresSafeArea()
        }
}
