//
//  SarahHome.swift
//  mawrooth
//
//  Created by ساره القرني on 10/04/1447 AH.
//
import SwiftUI
/*
extension Color {
    /// Initializes a Color from a hex string (e.g., "#FF4500" or "FF4500").
    /// - Parameter hex: The hexadecimal color string.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        // Determine if the hex string includes the alpha component (RGBA or RRGGBBAA)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (e.g., F0F)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (e.g., FF4500)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RRGGBBAA (e.g., FF4500FF)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if format is wrong
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
*/
struct ContentView: View {
    // Each button has its own scale state
    @State private var startButtonScale: CGFloat = 1.0
    @State private var iconButtonScale: CGFloat = 1.0
    
    // Define the custom colors based on the image's hex values
    let customOrange = Color(red: 238/255, green: 100/255, blue: 40/255) // The orange text color
    let customPurple = Color(red: 141/255, green: 135/255, blue: 192/255) // The purple text color
    
    private func animateButton(scale: inout CGFloat, isPressed: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = isPressed ? 0.95 : 1.0
        }
    }

    var body: some View {
        ZStack {
            // Background
      
            Image("Ima")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            ZStack{
                Image("Z")        // original size preserved
                     .padding(.top, -368)  // optional, distance from top of screen
                     .padding(.leading, -68)
                 
                 Spacer()  }
            .ignoresSafeArea()
            
            
            
            VStack {
            
                Image("TXT")
               .padding(.top, 50) // Adjust top padding as neede
                Spacer()

                // "ابدأ" Button
                Button(action: {
                    animateButton(scale: &startButtonScale, isPressed: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateButton(scale: &startButtonScale, isPressed: false)
                        print("ابدأ Button Tapped!")
                    }
                }) {
                    Text("ابدأ")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 72) // fixed size
                        .background(customOrange)
                        .cornerRadius(55)
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                }
                .scaleEffect(startButtonScale)
                
                Spacer().frame(height: 20)
                
                // Icon Button
                Button(action: {
                    animateButton(scale: &iconButtonScale, isPressed: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateButton(scale: &iconButtonScale, isPressed: false)
                        print("Icon Button Tapped!")
                    }
                }) {
                    Image(systemName: "book.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 72) // same width & height as orange button
                        .background(customPurple)
                        .cornerRadius(55)
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                }
                .scaleEffect(iconButtonScale)
                
                Spacer() // This will now occupy the remaining space at the bottom
            }
            
            .padding(.bottom, -200)
        }
    }
}

#Preview {
    ContentView()
}

