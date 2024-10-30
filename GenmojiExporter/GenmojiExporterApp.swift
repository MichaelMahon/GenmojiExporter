//
//  GenmojiExporterApp.swift
//  GenmojiExporter
//
//  Created by Mike Mahon on 10/29/24.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct GenmojiExporterApp: App {
    
    init() {
        try? Tips.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    Genmoji.self,
                ])
        }
    }
}
