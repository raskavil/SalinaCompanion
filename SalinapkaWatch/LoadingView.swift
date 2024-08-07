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
            VStack(alignment: .trailing, spacing: -14) {
                if shown {
                    Image(.cityBackground)
                        .resizable()
                        .frame(width: 75, height: 75)
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .move(edge: .trailing))
                            .combined(with: .move(edge: .trailing))
                            .combined(with: .move(edge: .trailing))
                        )
                    
                    Image(.tramBackground)
                        .resizable()
                        .frame(width: 113, height: 64)
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
                    .frame(width: 24, height: 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            VStack(spacing: -49) {
                if closed {
                    Knife(angle: .degrees(-47))
                        .foregroundStyle(.background)
                        .rotationEffect(.degrees(180))
                        .transition(.move(edge: .top))
                    Knife(angle: .degrees(-47))
                        .foregroundStyle(.background)
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

struct LoadingScreenPreviews: PreviewProvider {
    
    private struct ButtonView: View {
        
        @State var loadingHidden = false
        
        var body: some View {
            Color.red
                .ignoresSafeArea()
                .overlay {
                    LoadingView(isHidden: $loadingHidden)
                        .ignoresSafeArea()
                }
                .overlay {
                    Button("Hide") {
                        loadingHidden.toggle()
                    }
                }
        }
    }
    
    static var previews: some View {
        ButtonView()
    }
    
}
