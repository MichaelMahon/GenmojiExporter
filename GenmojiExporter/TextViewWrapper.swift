//
//  TextViewWrapper.swift
//  GenmojiExporter
//
//  Created by Mike Mahon on 10/29/24.
//

import Foundation
import UIKit
import SwiftUI

struct TextViewWrapper: UIViewRepresentable {
    
    var addGenmoji: (Genmoji) -> Void
    
    init(
        addGenmoji: @escaping (Genmoji) -> Void
    ) {
        self.addGenmoji = addGenmoji
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 36)
        textView.isEditable = true
        textView.isScrollEnabled = true
        
        textView.supportsAdaptiveImageGlyph = true
        textView.keyboardType = .default
        
        textView.becomeFirstResponder()
        
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewWrapper
        
        init(parent: TextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            
            let textContents = textView.textStorage
            
            do {
                let rtfData = try textContents.data(from: NSRange(location: 0, length: textContents.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
                
                let textFromData = try NSAttributedString(data: rtfData, documentAttributes: nil)
                
                guard let genmoji = getGenmoji(from: textFromData) else { return }
                
                parent.addGenmoji(genmoji)
            } catch {
                debugPrint(String(describing: error))
            }
        }
        
        func getGenmoji(from attrStr: NSAttributedString) -> Genmoji? {
            let string = attrStr.string
            var imageRanges: [(NSRange, String)] = []
            var imageData: [String: Data] = [:]
            
            var genmoji: Genmoji?
            
            attrStr.enumerateAttribute(.adaptiveImageGlyph, in: NSMakeRange(0, attrStr.length)) { (value, range, stop) in
                if let glyph = value as? NSAdaptiveImageGlyph {
                    let id = glyph.contentIdentifier
                    imageRanges.append((range, id))
                    if imageData[id] == nil {
                        imageData[id] = glyph.imageContent
                    }
                    
                    if let image = glyph
                        .image(
                            forProposedSize: CGSize(width: 512, height: 512),
                            scaleFactor: UIScreen.main.scale,
                            imageOffset: UnsafeMutablePointer<CGPoint>.allocate(capacity: 1),
                            imageSize: UnsafeMutablePointer<CGSize>.allocate(capacity: 1)
                        ) {
                        
                        genmoji = Genmoji(
                            id: glyph.contentIdentifier,
                            genmojiDescription: glyph.contentDescription,
                            image: UIImage(cgImage: image)
                        )
                        
                    }
                }
            }
            return genmoji
        }
    }
}
