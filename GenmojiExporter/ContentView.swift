//
//  ContentView.swift
//  GenmojiExporter
//
//  Created by Mike Mahon on 10/29/24.
//

import SwiftUI
import SwiftData
import TipKit

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    private let tip = GenmmojiLibraryTip()
    
    @Query(sort: \Genmoji.createdAt, order: .reverse) var genmojis: [Genmoji]
    @State private var showingAddGenmojiSheet = true
    
    @State private var genmojiToShare: Genmoji?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    struct GenmmojiLibraryTip: Tip {
        var title: Text {
            Text("Save and delete Genmoji")
        }
        
        var message: Text? {
            Text("Long press to save a Genmoji. Tripple tap to delete it from the library.")
        }
    }
    
    var body: some View {
        NavigationStack {
            TipView(tip)
                .padding()
            ScrollView(showsIndicators: false) {
                genMojiGrid
            }
            .sheet(isPresented: $showingAddGenmojiSheet) {
                addGenmojiSheet
            }
            .sheet(item: $genmojiToShare) { genmoji in
                if let pngImage = genmoji.image.pngData() {
                    ShareSheet(activityItems: [pngImage])
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddGenmojiSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationTitle("Genmoji Library")
        }
    }
    
    @ViewBuilder
    var genMojiGrid: some View {
        Group {
            if genmojis.isEmpty {
                Text("Tap the plus button to add a new genmoji.")
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(genmojis, id: \.id) { genmoji in
                        GenmojiItem(genmoji: genmoji)
                            .onLongPressGesture {
                                genmojiToShare = genmoji
                            }
                            .onTapGesture(count: 3) {
                                context.delete(genmoji)
                            }
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var addGenmojiSheet: some View {
        VStack {
            Text("Place a Genmoji in the text field to extract the image.")
                .font(.headline)
            TextViewWrapper(addGenmoji: { newGenmoji in
                context.insert(newGenmoji)
                showingAddGenmojiSheet = false
            })
            .frame(width: 60, height: 60)
            .clipShape(
                RoundedRectangle(cornerRadius: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.gray, lineWidth: 2)
            )
        }
        .presentationDetents([.fraction(0.25)])
    }
}

struct GenmojiItem: View {
    @State var genmoji: Genmoji
    
    var body: some View {
        Image(uiImage: genmoji.image)
            .resizable()
            .scaledToFit()
            .background(Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
