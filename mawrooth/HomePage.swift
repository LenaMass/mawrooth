import SwiftUI

struct ContentView: View {
    
    // Shared data store for the whole app
    @StateObject private var mawroothStore = MawroothDataStore()
    
    @State private var startButtonScale: CGFloat = 1.0
    @State private var iconButtonScale: CGFloat = 1.0
    
    // Controls navigation to the GameScreen
    @State private var navigateToGame = false
    
    // Controls showing CardPage
    @State private var showingCardPage = false
    
    let customOrange = Color(red: 238/255, green: 100/255, blue: 40/255)
    let customPurple = Color(red: 141/255, green: 135/255, blue: 192/255)
    
    private func animateButton(scale: inout CGFloat, isPressed: Bool) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scale = isPressed ? 0.95 : 1.0
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Image("Ima")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                ZStack {
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
                    
                    // START BUTTON
                    Button {
                        animateButton(scale: &startButtonScale, isPressed: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                            animateButton(scale: &startButtonScale, isPressed: false)
                            navigateToGame = true   // modern navigation triggers here
                        }
                    } label: {
                        Text("ابدأ")
                            .font(.system(size: 30, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 180, height: 60)
                            .background(customOrange)
                            .cornerRadius(55)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 5, y: 4)
                            .scaleEffect(startButtonScale)
                    }
                    
                    Spacer().frame(height: 10)
                    
                    // Icon Button -> CardPage
                    Button {
                        animateButton(scale: &iconButtonScale, isPressed: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            animateButton(scale: &iconButtonScale, isPressed: false)
                            showingCardPage = true
                        }
                    } label: {
                        Image(systemName: "book.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 145, height: 50)
                            .background(customPurple)
                            .cornerRadius(55)
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 5, y: 4)
                    }
                    .scaleEffect(iconButtonScale)
                    
                    Spacer()
                }
                .padding(.bottom, -200)
            }
            
            // ⭐ Modern navigationDestination
            .navigationDestination(isPresented: $navigateToGame) {
                GameScreen()
                    .environmentObject(mawroothStore)
            }
        }
        
        // Full screen cover for CardPage
        .fullScreenCover(isPresented: $showingCardPage) {
            CardPage()
                .environmentObject(mawroothStore)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MawroothDataStore())
}

