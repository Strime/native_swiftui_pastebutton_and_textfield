//
//  TextFieldView.swift
//  Runner
//
//  Created by kite on 2023/09/12.
//

import SwiftUI

struct TextFieldSwiftUIView: View {
    @State var textValue: String = ""
    var method: (String?) -> Void
    var labelText = ""
    var borderColor: Color = Color(.lightGray).opacity(0.5)
    var focusedBorderColor: Color = Color.blue
    var backgroundColor: Color = Color.white
    var textColor: Color = Color.black
    var cornerRadius: CGFloat = 8.0
    var fontSize: CGFloat = 14.0
    var contentPadding: EdgeInsets = EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
    @State private var isFocused: Bool = false
    
    init(seed: [String: Any], method: @escaping (String?) -> Void) {
        self.method = method
        self.labelText = seed["labelText"] as! String
        
        // Options de personnalisation supplémentaires
        if let borderColorHex = seed["borderColor"] as? String {
            self.borderColor = Color(hex: borderColorHex) ?? self.borderColor
        }
        
        if let focusedBorderColorHex = seed["focusedBorderColor"] as? String {
            self.focusedBorderColor = Color(hex: focusedBorderColorHex) ?? self.focusedBorderColor
        }
        
        if let backgroundColorHex = seed["backgroundColor"] as? String {
            self.backgroundColor = Color(hex: backgroundColorHex) ?? self.backgroundColor
        }
        
        if let textColorHex = seed["textColor"] as? String {
            self.textColor = Color(hex: textColorHex) ?? self.textColor
        }
        
        if let radius = seed["cornerRadius"] as? CGFloat {
            self.cornerRadius = radius
        }
        
        if let fontSize = seed["fontSize"] as? CGFloat {
            self.fontSize = fontSize
        }
        
        if let padding = seed["padding"] as? [String: CGFloat],
           let top = padding["top"],
           let leading = padding["leading"],
           let bottom = padding["bottom"],
           let trailing = padding["trailing"] {
            self.contentPadding = EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
        }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Champ de texte principal
            TextField("", text: $textValue.onChange(perform: {
                self.method(self.textValue)
            }))
            .padding(contentPadding)
            .font(.system(size: fontSize))
            .foregroundColor(textColor)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isFocused ? focusedBorderColor : borderColor, lineWidth: isFocused ? 2.0 : 1.0)
            )
            .onTapGesture {
                isFocused = true
            }
            .onAppear {
                // Masquer le clavier lorsque l'utilisateur tape en dehors du champ de texte
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isFocused = false
                }
            }
            
            // Placeholder texte
            if textValue.isEmpty {
                Text(labelText)
                    .font(.system(size: fontSize))
                    .foregroundColor(Color.gray.opacity(0.7))
                    .padding(contentPadding)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Extension pour initialiser une couleur à partir d'une valeur hexadécimale
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

extension Binding {
    func onChange(perform action: @escaping () -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: {
                self.wrappedValue = $0
                action()
            }
        )
    }
}
