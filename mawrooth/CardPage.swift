//
//  ContentView.swift
//  mawrooth
//
//  Created by Lena Saeed Alhuthali on 08/04/1447 AH.
//

import SwiftUI

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

struct CardPage: View



{
    
    let customGreen = Color(hex: "#21754D")
    var body: some View
    
    {
        NavigationStack {
            VStack{
                
                
                
                ZStack {
                    
                    Image("BG")
                     .aspectRatio(contentMode: .fill)
                      .frame(width: 2000, height: 5000)
                        .ignoresSafeArea(edges: .all)
//                    
//                    Text("موروثي")
//                        .font(.largeTitle)
//                        .fontWeight(.heavy)
//                        .foregroundColor(customGreen)
//                        .padding(.top,-330)
//                        .padding(.horizontal)
//                        .font(.custom("TheYearofHandicrafts-Bold.otf", size: 30))
//                    
                    ZStack {
                        Circle()
                            .fill(Color(hex: "8D87C0")) // circle color
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "F1B438")) //
                    }
                }
                //        Button {
                //            // Action
                //            print("Custom image tapped!")
                //        } label: {
                //            Image("Arrow") //
                //                .resizable()
                //                .frame(width: 60, height: 50)
                //                .clipShape(Circle())
                //                .padding(.top, -330)
                //                .padding(.leading, -1)
                
            }
            
            
            .navigationTitle("موروثي")
            
        }

}
      
}
          
        
          
            
    
        
   
        //.padding()
    

#Preview {
    
    CardPage()
}
