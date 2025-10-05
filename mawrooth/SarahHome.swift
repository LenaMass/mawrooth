import SwiftUI

struct ContentView: View {
    
    // Each button has its own scale state
    @State private var startButtonScale: CGFloat = 1.0
    @State private var iconButtonScale: CGFloat = 1.0
    
    // 🎯 KEY: State to control the modal presentation of CardPage
    @State private var showingCardPage = false
    
    // Define the custom colors based on the image's hex values
    // Assuming 238/100/40 is #EE6428 and 141/135/192 is #8D87C0
    let customOrange = Color(red: 238/255, green: 100/255, blue: 40/255)
    let customPurple = Color(red: 141/255, green: 135/255, blue: 192/255)
    
    private func animateButton(scale: inout CGFloat, isPressed: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = isPressed ? 0.95 : 1.0
        }
    }

    var body: some View {
        // The main view container does not need a NavigationStack here
        ZStack {
            // Background
            Image("Ima")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // This ZStack containing Image("Z") looks complex and might be causing issues.
            // I'm keeping it as you provided, but be aware of the large negative padding.
            ZStack{
                Image("Z")       // original size preserved
                    .padding(.top, -359)
                    .padding(.leading, -68)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack {
                
                Image("TXT")
                    .padding(.top, 50)
                
                Spacer()

                // "ابدأ" Button (Start Button)
                Button(action: {
                    animateButton(scale: &startButtonScale, isPressed: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateButton(scale: &startButtonScale, isPressed: false)
                        
                     
                    }
                }) {
                    Text("ابدأ")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 72)
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
                        // 🎯 ACTION: Toggles the state to present CardPage
                        showingCardPage = true
                        print("")
                    }
                }) {
                    Image(systemName: "book.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 72)
                        .background(customPurple)
                        .cornerRadius(55)
                        .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 4)
                }
                .scaleEffect(iconButtonScale)
                
                Spacer() // Occupy remaining space
            }
            .padding(.bottom, -200) // Your original padding
        }
        // 🎯 KEY: This presents CardPage when showingCardPage is true.
        .fullScreenCover(isPresented: $showingCardPage) {
            // When CardPage calls dismiss(), the user returns here.
            CardPage()
        }
    }
}

#Preview {
    ContentView()
}
