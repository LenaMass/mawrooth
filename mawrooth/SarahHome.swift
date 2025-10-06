import SwiftUI

// Assume the Haptics, Font extension, Color extension, GCard, GameVM, GameScreen, and CardPage structs
// from the previous script are available in the same file or imported module.

struct ContentView: View {
    
    // Each button has its own scale state
    @State private var startButtonScale: CGFloat = 1.0
    @State private var iconButtonScale: CGFloat = 1.0
    
    // 🎯 KEY: State to control the modal presentation of CardPage
    @State private var showingCardPage = false
    
    // Define the custom colors based on the image's hex values
    let customOrange = Color(red: 238/255, green: 100/255, blue: 40/255)
    let customPurple = Color(red: 141/255, green: 135/255, blue: 192/255)
    
    private func animateButton(scale: inout CGFloat, isPressed: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = isPressed ? 0.95 : 1.0
        }
    }

    var body: some View {
        // 🚨 IMPORTANT: Wrap in NavigationStack to allow NavigationLink to work
        NavigationStack {
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
                    Image("Z")
                        .padding(.top, -359)
                        .padding(.leading, -68)
                    Spacer()
                }
                .ignoresSafeArea()
                
                VStack {
                    
                    Image("TXT")
                        .padding(.top, 50)
                    
                    Spacer()

                    // "ابدأ" Button (Start Button) - Now a NavigationLink
                    // We keep the Button style inside the NavigationLink
                    NavigationLink {
                        // 🎯 ACTION: Navigate to the GameScreen
                        GameScreen()
                    } label: {
                        Text("ابدأ")
                        // ⚠️ Note: I'm replacing the custom font with a standard one
                            // as "TheYearofHandicrafts-Bold" is likely missing.
                            // If you have the font file, ensure it's imported correctly.
                            .font(.system(size: 30, weight: .heavy))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 60)
                            .background(customOrange)
                            .cornerRadius(55)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 5, y: 4)
                            // Apply scale effect for visual feedback
                            .scaleEffect(startButtonScale)
                            // Use a button style to capture press and animate the scale effect
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        animateButton(scale: &startButtonScale, isPressed: true)
                                    }
                                    .onEnded { _ in
                                        animateButton(scale: &startButtonScale, isPressed: false)
                                    }
                            )
                    }
                    
                    Spacer().frame(height: 10)
                    
                    // Icon Button (Stays a regular Button presenting CardPage modally)
                    Button(action: {
                        animateButton(scale: &iconButtonScale, isPressed: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateButton(scale: &iconButtonScale, isPressed: false)
                            showingCardPage = true
                        }
                    }) {
                        Image(systemName: "book.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 145, height: 50)
                            .background(customPurple)
                            .cornerRadius(55)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 5, y: 4)
                    }
                    .scaleEffect(iconButtonScale)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                animateButton(scale: &iconButtonScale, isPressed: true)
                            }
                            .onEnded { _ in
                                animateButton(scale: &iconButtonScale, isPressed: false)
                            }
                    )
                    
                    Spacer() // Occupy remaining space
                }
                .padding(.bottom, -200) // Your original padding
            }
        }
        // 🎯 KEY: This presents CardPage when showingCardPage is true.
        .fullScreenCover(isPresented: $showingCardPage) {
            CardPage()
        }
    }
}

#Preview {
    ContentView()
}
