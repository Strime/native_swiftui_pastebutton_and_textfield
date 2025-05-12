//
//  SwiftUIPasteButtonView.swift
//  Runner
//
//  Created by kite on 2023/09/07.
//

import SwiftUI

struct PasteButtonSwiftUIView: View {
    @State var buttonID: String = ""
    var method: (String?) -> Void
    var color: Color
    var width: Double
    var height: Double
    
    init(seed: [String: Any], bodyColor: Color, method: @escaping (String?) -> Void) {
        buttonID = UUID().uuidString
        self.method = method
        self.color = bodyColor
        self.width = seed["width"] as? Double ?? 40.0
        self.height = seed["height"] as? Double ?? 40.0
    }
    
    var body: some View {
        Button(action: {
            if let string = UIPasteboard.general.string {
                method(string)
            }
        }) {
            Image(systemName: "doc.on.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(color)
        }
        .frame(width: width, height: height)
        .background(Color.clear) 
        .cornerRadius(8)
    }
}
