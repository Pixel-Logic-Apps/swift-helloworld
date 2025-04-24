import SwiftUI

struct InputView: View {
    let placeholder: String
    @Binding var text: String
    let style: [String: Any]?

    // 1️⃣ Propriedade computada que monta o TextField estilizado e o envolve em AnyView
    private var inputContent: AnyView {
        var view: AnyView = AnyView(TextField(placeholder, text: $text))
        
        if let style = style {
            if let fontSize = cg(style["fontSize"]) {
                let weight = mapFontWeight(style["fontWeight"] as? String)
                view = AnyView(view.font(.system(size: fontSize, weight: weight)))
            }
            if let fgHex = style["foreground"] as? String, let color = Color(hex: fgHex) {
                view = AnyView(view.foregroundColor(color))
            }
            if let alignment = style["textAlignment"] as? String {
                let align: TextAlignment = {
                    switch alignment.lowercased() {
                    case "center":   return .center
                    case "trailing": return .trailing
                    default:         return .leading
                    }
                }()
                view = AnyView(view.multilineTextAlignment(align))
            }
            if let padding = cg(style["padding"]) {
                view = AnyView(view.padding(padding))
            }
            if let bgHex = style["background"] as? String, let bgColor = Color(hex: bgHex) {
                let radius = cg(style["cornerRadius"]) ?? 0
                view = AnyView(
                    view.background(RoundedRectangle(cornerRadius: radius).fill(bgColor))
                )
            }
            // Borda
            if let borderHex   = style["borderColor"]  as? String,
               let borderColor = Color(hex: borderHex),
               let bw          = cg(style["borderWidth"])
            {
                let radius = cg(style["cornerRadius"]) ?? 0
                view = AnyView(
                  view
                    // se você quiser ver a borda, geralmente é bom ter padding:
                    .padding(cg(style["padding"]) ?? 0)
                    .overlay(
                      RoundedRectangle(cornerRadius: radius)
                        .stroke(borderColor, lineWidth: bw)
                    )
                )
            }

        }
        
        return view
    }

    // 2️⃣ body agora retorna apenas inputContent
    var body: some View {
        inputContent
    }

    // 3️⃣ mapeamento de peso de fonte
    private func mapFontWeight(_ weightString: String?) -> Font.Weight {
        switch weightString?.lowercased() {
        case "bold":   return .bold
        case "medium": return .medium
        default:       return .regular
        }
    }
    
    private func cg(_ any: Any?) -> CGFloat? {
        if let f = any as? CGFloat     { return f }
        if let d = any as? Double      { return CGFloat(d) }
        if let i = any as? Int         { return CGFloat(i) }
        return nil
    }

}
