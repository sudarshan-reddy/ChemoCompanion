import SwiftUI

struct NeuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.neuBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.neuShadowDark, lineWidth: 1)
                                    .blur(radius: 1)
                            )
                            .shadow(color: Color.neuShadowDark, radius: 3, x: 3, y: 3)
                            .shadow(color: Color.neuShadowLight, radius: 3, x: -3, y: -3)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.neuForeground)
                            .shadow(color: Color.neuShadowDark, radius: 5, x: 5, y: 5)
                            .shadow(color: Color.neuShadowLight, radius: 5, x: -5, y: -5)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct NeuCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.neuForeground)
            .cornerRadius(15)
            .shadow(color: Color.neuShadowDark, radius: 5, x: 5, y: 5)
            .shadow(color: Color.neuShadowLight, radius: 5, x: -5, y: -5)
    }
}

// Custom Slider Track
struct NeuSliderTrack: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.neuBackground)
                    .frame(height: 6)
                    .shadow(color: Color.neuShadowLight, radius: 2, x: -2, y: -2)
                    .shadow(color: Color.neuShadowDark, radius: 2, x: 2, y: 2)
                
                // Filled track
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.neuPrimary)
                    .frame(width: geometry.size.width * CGFloat(value), height: 6)
            }
        }
    }
}

// Custom Slider Thumb
struct NeuSliderThumb: View {
    var body: some View {
        Circle()
            .fill(Color.neuForeground)
            .frame(width: 24, height: 24)
            .shadow(color: Color.neuShadowDark, radius: 4, x: 4, y: 4)
            .shadow(color: Color.neuShadowLight, radius: 4, x: -4, y: -4)
    }
}

// Neumorphic Slider
struct NeuSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                NeuSliderTrack(value: normalizedValue)
                
                NeuSliderThumb()
                    .position(x: thumbPosition(in: geometry), y: geometry.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                updateValue(at: gesture.location.x, in: geometry)
                            }
                    )
            }
        }
        .frame(height: 24)
    }
    
    private var normalizedValue: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    private func thumbPosition(in geometry: GeometryProxy) -> CGFloat {
        let normalized = normalizedValue
        return geometry.size.width * CGFloat(normalized)
    }
    
    private func updateValue(at position: CGFloat, in geometry: GeometryProxy) {
        let normalized = max(0, min(1, position / geometry.size.width))
        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(normalized)
        value = newValue
    }
}

// Extension for easy use
extension View {
    func neuCard() -> some View {
        modifier(NeuCardModifier())
    }
}
