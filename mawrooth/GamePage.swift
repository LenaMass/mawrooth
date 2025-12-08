import SwiftUI
import AudioToolbox

enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func light(){ UIImpactFeedbackGenerator(style: .light).impactOccurred() }
}

extension Font {
    static func arabicHeadline(_ size: CGFloat, weight: Weight = .bold) -> Font {
        let preferredArabicNames = ["SF Arabic", "Cairo", "GE SS Two", "DINNextLTArabic"]
        if let name = preferredArabicNames.first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size).weight(weight)
        } else {
            return .system(size: size, weight: .bold, design: .rounded)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
    
    static let burntBrown = Color(red: 92/255, green: 58/255, blue: 46/255)
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct PopUpMessageView: View {
    @Environment(\.dismiss) var dismiss

    let popUpTitle: String
    let titleColor: Color
    let titleFontSize: CGFloat
    let displayMessage: String
    let messageColor: Color
    let messageFontSize: CGFloat
    let saveAction: () -> Void
    let closeAction: () -> Void

    let backgroundColor = Color(hex: "8D87C0")
    let saveButtonColor = Color(hex: "F1B438")
    let textcolor = Color(hex: "EE6428")
    
    @State private var canClose = false
    @State private var countdown = 5
    private let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(backgroundColor)
                    .frame(width: 320, height: 450)
                    .overlay(
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                Image("BGmessage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                
                                if canClose {
                                    Button {
                                        closeAction()
                                        dismiss()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(saveButtonColor)
                                            .background(Color.white.opacity(0.8))
                                            .clipShape(Circle())
                                            .padding(.top, 60)
                                            .padding(.leading, 15)
                                    }
                                } else {
                                    ZStack {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(saveButtonColor.opacity(0.25))
                                            .background(Color.white.opacity(0.5))
                                            .clipShape(Circle())
                                        
                                        Text("\(countdown)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.top, 60)
                                    .padding(.leading, 15)
                                }
                            }
                            .frame(height: 180)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                            
                            VStack(spacing: 15) {
                                Text(popUpTitle)
                                    .font(.system(size: titleFontSize, weight: .bold))
                                    .foregroundColor(titleColor)
                                    .padding(.top, 10)
                                    .offset(y: -10)
                                
                                Text(displayMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(messageColor)
                                    .font(.system(size: messageFontSize))
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 10)
                            }
                            .frame(height: 150)
                            
                            Spacer()
                            
                            Button(action: saveAction) {
                                Text("احفظ موروثك")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(textcolor)
                                    .frame(width: 200, height: 55)
                                    .background(saveButtonColor)
                                    .cornerRadius(55)
                            }
                            .padding(.bottom, 30)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(radius: 20)
            }
        }
        .onAppear {
            canClose = false
            countdown = 5
        }
        .onReceive(countdownTimer) { _ in
            guard !canClose else { return }
            if countdown > 0 { countdown -= 1 }
            if countdown == 0 { canClose = true }
        }
    }
}

struct LossPopUpMessageView: View {
    @Environment(\.dismiss) var dismiss

    let popUpTitle: String
    let titleColor: Color
    let titleFontSize: CGFloat
    let displayMessage: String
    let messageColor: Color
    let messageFontSize: CGFloat
    let closeAction: () -> Void

    let backgroundColor = Color(hex: "8D87C0")
    let closeButtonColor = Color(hex: "F1B438")
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(backgroundColor)
                    .frame(width: 320, height: 450)
                    .overlay(
                        VStack(spacing: 0) {
                            ZStack(alignment: .topLeading) {
                                Image("BGmessage")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                    
                                Button {
                                    closeAction()
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(closeButtonColor)
                                        .background(Color.white.opacity(0.8))
                                        .clipShape(Circle())
                                        .padding(.top, 60)
                                        .padding(.leading, 15)
                                }
                            }
                            .frame(height: 180)
                            .cornerRadius(30, corners: [.topLeft, .topRight])
                            
                            VStack(spacing: 15) {
                                Text(popUpTitle)
                                    .font(.system(size: titleFontSize, weight: .bold))
                                    .foregroundColor(titleColor)
                                    .padding(.top, 10)
                                    
                                Text(displayMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(messageColor)
                                    .font(.system(size: messageFontSize))
                                    .padding(.horizontal, 15)
                                    .padding(.bottom, 10)
                            }
                            .frame(height: 150)
                            
                            Spacer()
                            Spacer()
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(radius: 20)
            }
        }
    }
}

struct gamePage: View {
    @StateObject private var mawroothStore = MawroothDataStore()

    var body: some View {
        NavigationStack {
            GameScreen()
                .environmentObject(mawroothStore)
        }
    }
}

struct GameScreen: View {
    @StateObject private var vm = GameVM()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mawroothStore: MawroothDataStore
    
    @State private var isFlashing = false
    
    private var isCriticalTime: Bool {
        vm.timeRemaining <= 10 && vm.timeRemaining > 0
    }

    var body: some View {
        ZStack {
            if let bg = UIImage(named: "BG") {
                Image(uiImage: bg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        vm.stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title3.weight(.semibold))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(vm.timeString)
                            .font(.system(.subheadline, design: .rounded).monospacedDigit())
                    }
                    .foregroundColor(isCriticalTime ? .red : .primary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule().fill(
                            isCriticalTime
                            ? Color.red.opacity(0.15)
                            : Color.purple.opacity(0.15)
                        )
                    )
                    .opacity(isCriticalTime ? (isFlashing ? 0.25 : 1.0) : 1.0)
                    .animation(
                        isCriticalTime
                        ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                        : .default,
                        value: isFlashing
                    )

                    Button {
                        vm.restart()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(vm.lockBoard)
                }
                .tint(.purple)
                .padding(.horizontal)
                .padding(.top, 6)
                .overlay(
                    Text("طابق الكروت")
                        .font(.arabicHeadline(22))
                        .offset(y: -10)
                )

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                    spacing: 12
                ) {
                    ForEach(vm.cards) { card in
                        CardView(card: card)
                            .onTapGesture { vm.tap(card) }
                            .disabled(card.isMatched || card.isFaceUp || vm.lockBoard || vm.timeRemaining == 0)
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 6)

                HStack {
                    Text("مُطابَقات: \(vm.matchedPairs)/\(vm.totalPairs)")
                    Spacer()
                }
                .font(.callout)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear { vm.stopTimer() }
        .onChange(of: vm.timeRemaining) { oldValue, newValue in
            if newValue == 10 && oldValue > 10 {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isFlashing.toggle()
                }
            }
            if newValue == 0 || newValue > 10 {
                isFlashing = false
            }
        }
        .onChange(of: vm.showWinPopUp) { _, newValue in
            if newValue {
                vm.selectRandomWinMessage(excludingSavedFrom: mawroothStore)
            }
        }
        .fullScreenCover(isPresented: $vm.showWinPopUp) {
            PopUpMessageView(
                popUpTitle: "إنجاز عظيم!",
                titleColor: Color.yellow,
                titleFontSize: 27,
                displayMessage: vm.currentWinMessage,
                messageColor: .white,
                messageFontSize: 16,
                saveAction: {
                    let timeSpent = 60 - vm.timeRemaining
                    let timeRecord = "الزمن: \(timeSpent) ثانية"
                    let messageToSave = vm.currentWinMessage
                    mawroothStore.save(message: messageToSave, timeTaken: timeRecord)

                    vm.showWinPopUp = false
                    vm.restart()
                },
                closeAction: {
                    vm.showWinPopUp = false
                    vm.restart()
                }
            )
            .presentationBackground(.clear)
        }
        .fullScreenCover(isPresented: $vm.showLossPopUp) {
            LossPopUpMessageView(
                popUpTitle: "خلص الوقت، العوض بالجايات",
                titleColor: .red,
                titleFontSize: 30,
                displayMessage: "",
                messageColor: .white,
                messageFontSize: 16,
                closeAction: {
                    vm.showLossPopUp = false
                    vm.restart()
                }
            )
            .presentationBackground(.clear)
        }
    }
}

struct GCard: Identifiable, Equatable {
    let id = UUID()
    let pairId: Int?
    let imageName: String
    var isFaceUp = false
    var isMatched = false
    var isTrap: Bool { pairId == nil }
}

final class GameVM: ObservableObject {
    @Published var cards: [GCard] = []
    @Published var timeRemaining = 60
    @Published var lockBoard = false
    @Published var showWinPopUp = false
    @Published var showLossPopUp = false
    @Published var endTitle = ""
    @Published var endMessage = ""
    @Published var currentWinMessage: String = ""

    private var timer: Timer?

    private let faces: [String] = [
        "char_sheikh_orange", "char_sheikh_green",
        "char_female_teal", "char_female_beige"
    ]
    
    private let trapPenaltySeconds = 10

    private let saudiHeritageFacts: [String] = [
        "البن الخولاني يُزرع على قمم جبال جازان منذ قرون، وندرته تجعله ضمن أندر 1% من أنواع البن المزروعة على ارتفاعات شاهقة بهذا النقاء.",
        "السدو نسيج بدوي تصنعه النساء من وبر الإبل والصوف، ولكل رمز فيه معنى محدد؛ فالمثلثات تمثل الجبال، والخطوط تمثل طرق الترحال",
        "النقش على المعادن حرفة تُزين الذهب والفضة بزخارف دقيقة، وكانت القطع المنقوشة تُهدى كرسائل تحمل معاني اجتماعية واحتفالية",
        "العرضة رقصة وطنية تُؤدّى بالسيوف والطبول، وأصلها يعود لساحات الحرب حيث كانت تُقام قبل المعركة لرفع حماس المقاتلين.",
        "حداء الإبل غناء يستخدمه الرعاة لتوجيه الإبل… والإبل تستجيب فعليًا للحن.",
        "الصقارة فن تربية الصقور والصيد بها، وبعض العائلات سمّت أبناءها بأسماء صقور إعجابًا بصفات القوة.",
        "الورد الطائفي يُزرع في جبال الهدا والشفا ورائحته مميزة.",
        "السمسمية آلة وترية ساحلية كانت ترافق البحّارة في السفر."
    ]
    
    func selectRandomWinMessage(excludingSavedFrom store: MawroothDataStore? = nil) {
        let saved = Set(store?.savedItems.map { $0.message } ?? [])
        let available = saudiHeritageFacts.filter { !saved.contains($0) }
        currentWinMessage = (available.isEmpty ? saudiHeritageFacts.randomElement() : available.randomElement()) ?? ""
    }

    var totalPairs: Int { Set(cards.compactMap { $0.pairId }).count }

    var matchedPairs: Int {
        let groups = Dictionary(grouping: cards.filter { $0.isMatched && !$0.isTrap }) { $0.pairId! }
        return groups.values.reduce(0) { $0 + ($1.count == 2 ? 1 : 0) }
    }

    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    init() { restart() }

    func restart() {
        stopTimer()
        timeRemaining = 60
        lockBoard = false
        showWinPopUp = false
        showLossPopUp = false
        
        var deck: [GCard] = []
        for (i, name) in faces.enumerated() {
            deck.append(GCard(pairId: i, imageName: name))
            deck.append(GCard(pairId: i, imageName: name))
        }
        deck.shuffle()

        var grid = Array(deck.prefix(8))
        let trap = GCard(pairId: nil, imageName: "trap_card")
        grid.insert(trap, at: Int.random(in: 0...8))

        cards = grid

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let s = self else { return }
            if s.timeRemaining > 0 {
                s.timeRemaining -= 1
                if s.matchedPairs == s.totalPairs { s.finish(won: true) }
            } else {
                s.lockBoard = true
                s.finish(won: false)
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func tap(_ card: GCard) {
        guard let i = cards.firstIndex(of: card),
              !cards[i].isMatched, !cards[i].isFaceUp,
              !lockBoard, timeRemaining > 0 else { return }

        if cards[i].isTrap {
            lockBoard = true
            cards[i].isFaceUp = true
            Haptics.warning()
            timeRemaining = max(0, timeRemaining - trapPenaltySeconds)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.timeRemaining == 0 {
                    self.lockBoard = true
                    self.finish(won: false)
                    return
                }
                if let idx = self.cards.firstIndex(where: { $0.id == card.id }) {
                    self.cards[idx].isFaceUp = false
                }
                self.lockBoard = false
            }
            return
        }

        cards[i].isFaceUp = true

        let up = cards.indices.filter {
            cards[$0].isFaceUp && !cards[$0].isMatched && !cards[$0].isTrap
        }

        if up.count == 2 {
            lockBoard = true
            let a = up[0], b = up[1]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                if self.cards[a].pairId == self.cards[b].pairId {
                    self.cards[a].isMatched = true
                    self.cards[b].isMatched = true
                    Haptics.success()
                } else {
                    self.cards[a].isFaceUp = false
                    self.cards[b].isFaceUp = false
                    Haptics.light()
                    Haptics.warning()
                }
                self.lockBoard = false
                if self.matchedPairs == self.totalPairs { self.finish(won: true) }
            }
        }
    }

    private func finish(won: Bool) {
        stopTimer()
        lockBoard = true
        if won {
            selectRandomWinMessage()
            showWinPopUp = true
            Haptics.success()
        } else {
            showLossPopUp = true
            Haptics.warning()
        }
    }
}

struct CardView: View {
    let card: GCard
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                    )

                if let ui = UIImage(named: "logo_card") {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    Image(systemName: "square.grid.3x3.fill").font(.title)
                }
            }
            .rotation3DEffect(.degrees(card.isFaceUp ? 180 : 0),
                              axis: (0, 1, 0))
            .opacity(card.isFaceUp ? 0 : 1)

            ZStack {
                if card.isTrap {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.burntBrown.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.burntBrown.opacity(0.9), lineWidth: 2)
                        )
                    VStack(spacing: 8) {
                        if let trapImg = UIImage(named: card.imageName) {
                            Image(uiImage: trapImg)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 42)
                        } else {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(Color.burntBrown)
                        }

                        Text("حكمك طاح وقيمك راح")
                            .font(.arabicHeadline(16))
                            .foregroundStyle(Color.burntBrown)
                        
                        Text("وقعت بالفخ")
                            .font(.caption)
                            .foregroundStyle(Color.burntBrown.opacity(0.9))
                    }
                    .padding(.vertical, 10)
                } else if let ui = UIImage(named: card.imageName) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white)
                }
            }
            .rotation3DEffect(.degrees(card.isFaceUp ? 0 : -180),
                              axis: (0, 1, 0))
            .opacity(card.isFaceUp ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
    }
}

