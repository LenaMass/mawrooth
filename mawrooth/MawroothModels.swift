//
//  MawroothModels.swift
//  mawrooth
//
//  Created by Lena Saeed Alhuthali on 15/04/1447 AH.
//

import SwiftUI // Import SwiftUI if you use @Published or other SwiftUI features

// MARK: - 1. Mawrooth Item Model (Define ONLY ONCE)
struct MawroothItem: Identifiable, Codable {
    var id = UUID()
    let message: String
    let date: Date
    let timeTaken: String
}

// MARK: - 2. Mawrooth Data Store (Define ONLY ONCE)
final class MawroothDataStore: ObservableObject {
    @Published var savedItems: [MawroothItem] = []
    
    // Placeholder init for the preview. Your actual app would load data here.
    init() {
        // Load data logic goes here
    }
    
    // Placeholder save function.
    func save(message: String, timeTaken: String) {
        let newItem = MawroothItem(message: message, date: Date(), timeTaken: timeTaken)
        savedItems.insert(newItem, at: 0) // Add to beginning for newest first
        // Save to UserDefaults/disk logic goes here
    }
}
