//
//  ContentView.swift
import SwiftUI

// MARK: - Color Extension
extension Color {
    /// Initializes a Color from a hex string (e.g., "#FF4500" or "FF4500").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Utility Function
func cardPageUndoAction() {
    print("Undo Action Button Tapped!")
}

// MARK: - CardPage View
struct CardPage: View {
    
    // 🎯 KEY: This environment variable dismisses the view presented modally.
    @Environment(\.dismiss) var dismiss
    
    let circleColor = Color(hex: "8D87C0")
    let iconColor = Color(hex: "F1B438")
    private let titleVerticalOffset: CGFloat = 16
    
    // 💡 FIX: Modified customToolbarButton to accept an icon size and weight
    private func customToolbarButton(systemName: String, size: CGFloat = 20, weight: Font.Weight = .bold) -> some View {
        ZStack {
            // Uncomment this if you want the purple circle background back, otherwise it's just the icon
            /*
            Circle()
                .fill(circleColor)
                .frame(width: 40, height: 40)
            */
            
            Image(systemName: systemName)
                .font(.system(size: size, weight: weight)) // <--- Controls the size
                .foregroundColor(circleColor) // Used circleColor for the tint as in your setup
        }
    }

    var body: some View {
        NavigationStack {
            
            ZStack {
                // 1. BACKGROUND LAYER
                Image("BG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
            .toolbar {
                
                // Left Button (Back to ContentView)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        // 🛠️ USAGE: You can now set the size directly here.
                        // Example: customToolbarButton(systemName: "chevron.backward", size: 28, weight: .heavy)
                        customToolbarButton(systemName: "chevron.backward", size: 28)
                    }
                }
                
                // Center Title (Principal)
                ToolbarItem(placement: .principal) {
                    Image("cardTitle")
                        .padding(.top, 20)
                }
                
            }
            
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    
    Color.white
        .fullScreenCover(isPresented: .constant(true)) {
            CardPage()
        }
}
