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
    
    private func customToolbarButton(systemName: String) -> some View {
        ZStack {
            Circle()
                .fill(circleColor)
                .frame(width: 40, height: 40)
            
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)
        }
    }

    var body: some View {
        NavigationStack {
            
            ZStack {
                // 1. BACKGROUND LAYER
                Image("BG")
                    .resizable()
                    //.aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(.all)
            
            }
            .toolbar {
                
                // Left Button (Back to ContentView)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                        dismiss()
                    } label: {
                        customToolbarButton(systemName: "chevron.backward")
                    }
                }
                
                // Center Title (Principal)
                ToolbarItem(placement: .principal) {
                    Image("cardTitle")
                        .padding(.top, 100)
                }
                
//                // Right Button (Trailing Edge) - Undo Action
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: cardPageUndoAction) {
//                        customToolbarButton(systemName: "arrow.uturn.backward")
//                    }
//                }
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
