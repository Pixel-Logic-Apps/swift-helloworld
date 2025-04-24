import SwiftUI

struct ButtonView: View {
    let value: String
    let style: [String: Any]?
    let onTap: () -> Void

    // Conteúdo do botão com estilos aplicados inline
    private var buttonContent: AnyView {
        var view: AnyView = AnyView(Text(value))
        guard let style = style else { return view }

        // Helper para converter Int/Double/CGFloat em CGFloat
        func cg(_ any: Any?) -> CGFloat? {
            if let f = any as? CGFloat { return f }
            if let d = any as? Double  { return CGFloat(d) }
            if let i = any as? Int     { return CGFloat(i) }
            return nil
        }

        // Fonte e peso
        if let fs = cg(style["fontSize"]) {
            let wt = mapFontWeight(style["fontWeight"] as? String)
            view = AnyView(view.font(.system(size: fs, weight: wt)))
        }

        // Cor do texto
        if let fg = style["foreground"] as? String,
           let fgColor = Color(hex: fg) {
            view = AnyView(view.foregroundColor(fgColor))
        }

        // Padding interno
        if let pd = cg(style["padding"]) {
            view = AnyView(view.padding(pd))
        }

        // Fundo + cornerRadius
        if let bg = style["background"] as? String,
           let bgColor = Color(hex: bg) {
            let cr = cg(style["cornerRadius"]) ?? 0
            view = AnyView(
                view
                    .background(RoundedRectangle(cornerRadius: cr).fill(bgColor))
            )
        }

        // Borda
        if let bc = style["borderColor"] as? String,
           let borderColor = Color(hex: bc),
           let bw = cg(style["borderWidth"]) {
            let cr = cg(style["cornerRadius"]) ?? 0
            view = AnyView(
                view
                    .overlay(
                        RoundedRectangle(cornerRadius: cr)
                            .stroke(borderColor, lineWidth: bw)
                    )
            )
        }

        // Sombra
        if let sr = cg(style["shadowRadius"]) {
            view = AnyView(view.shadow(radius: sr))
        }

        return view
    }

    var body: some View {
        Button(action: onTap) {
            buttonContent
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helper de peso de fonte
    private func mapFontWeight(_ str: String?) -> Font.Weight {
        switch str?.lowercased() {
        case "ultralight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        default:            return .regular
        }
    }
}
