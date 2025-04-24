import SwiftUI

// 1. Um ViewModifier que aplica o dicionário de estilos a qualquer View
struct StyleModifier: ViewModifier {
    let style: [String: Any]?

    func body(content: Content) -> some View {
        // Começo encapsulado em AnyView para permitir mutações sucessivas
        var view: AnyView = AnyView(content)

        guard let style = style else {
            return view
        }

        // Fonte
        if let fontSize = cg(style["fontSize"]) {
            let weight = mapFontWeight(style["fontWeight"] as? String)
            view = AnyView(view.font(.system(size: fontSize, weight: weight)))
        }

        // Cor do texto ou foreground
        if let fgHex = style["foreground"] as? String,
           let fgColor = Color(hex: fgHex) {
            view = AnyView(view.foregroundColor(fgColor))
        }

        // Padding
        if let padding = cg(style["padding"]) {
            view = AnyView(view.padding(padding))
        }

        // Background + cornerRadius
        if let bgHex = style["background"] as? String,
           let bgColor = Color(hex: bgHex) {
            let radius = cg(style["cornerRadius"]) ?? 0
            view = AnyView(
                view
                    .background(RoundedRectangle(cornerRadius: radius).fill(bgColor))
            )
        }

        // Borda
        if let borderHex = style["borderColor"] as? String,
           let borderColor = Color(hex: borderHex),
           let borderWidth = cg(style["borderWidth"]) {
            let radius = cg(style["cornerRadius"]) ?? 0
            view = AnyView(
                view.overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            )
        }

        // Sombra
        if let shadowRadius = cg(style["shadowRadius"]) {
            view = AnyView(view.shadow(radius: shadowRadius))
        }

        return view
    }

    private func mapFontWeight(_ str: String?) -> Font.Weight {
        switch str?.lowercased() {
        case "ultralight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        default:           return .regular
        }
    }
    
    private func cg(_ any: Any?) -> CGFloat? {
        if let f = any as? CGFloat     { return f }
        if let d = any as? Double      { return CGFloat(d) }
        if let i = any as? Int         { return CGFloat(i) }
        return nil
    }
}

// 2. O seu ButtonView, agora usando só Text + StyleModifier
struct ButtonView: View {
    let label: String
    let style: [String: Any]?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .modifier(StyleModifier(style: style))
        }
        .buttonStyle(.plain)
    }
}
