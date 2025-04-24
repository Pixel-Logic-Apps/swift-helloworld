import SwiftUI

struct TextView: View {
    let value: String
    let style: [String: Any]?

    // 1️⃣ Propriedade computada que monta o Text estilizado e o envolve em AnyView
    private var textContent: AnyView {
        var view: AnyView = AnyView(Text(value))

        guard let style = style else {
            return view
        }

        // Fontes (Sistema e Customizadas)
        if let fontName = style["fontName"] as? String,
           let fontSize = cg(style["fontSize"]) {
            view = AnyView(view.font(.custom(fontName, size: fontSize)))
        } else if let font = style["font"] as? String {
            switch font.lowercased() {
            case "largetitle": view = AnyView(view.font(.largeTitle))
            case "title":      view = AnyView(view.font(.title))
            case "title2":     view = AnyView(view.font(.title2))
            case "title3":     view = AnyView(view.font(.title3))
            case "headline":   view = AnyView(view.font(.headline))
            case "subheadline":view = AnyView(view.font(.subheadline))
            case "body":       view = AnyView(view.font(.body))
            case "callout":    view = AnyView(view.font(.callout))
            case "footnote":   view = AnyView(view.font(.footnote))
            case "caption":    view = AnyView(view.font(.caption))
            case "caption2":   view = AnyView(view.font(.caption2))
            default:
                if let fs = cg(style["fontSize"]) {
                    let weight = mapFontWeight(style["fontWeight"] as? String)
                    let design = mapFontDesign(style["fontDesign"] as? String)
                    view = AnyView(view.font(.system(size: fs, weight: weight, design: design)))
                }
            }
        } else if let fs = cg(style["fontSize"]) {
            let weight = mapFontWeight(style["fontWeight"] as? String)
            let design = mapFontDesign(style["fontDesign"] as? String)
            view = AnyView(view.font(.system(size: fs, weight: weight, design: design)))
        }

        // FontWeight / Bold / Italic
        if let fw = style["fontWeight"] as? String {
            view = AnyView(view.fontWeight(mapFontWeight(fw)))
        }
        if style["bold"] as? Bool == true {
            view = AnyView(view.bold())
        }
        if style["italic"] as? Bool == true {
            view = AnyView(view.italic())
        }

        // Underline / Strikethrough
        if style["underline"] as? Bool == true {
            let col = (style["underlineColor"] as? String).flatMap(Color.init(hex:))
            let pat = mapLineStylePattern(style["underlinePattern"] as? String)
            view = AnyView(view.underline(true, pattern: pat, color: col))
        }
        if style["strikethrough"] as? Bool == true {
            let col = (style["strikethroughColor"] as? String).flatMap(Color.init(hex:))
            let pat = mapLineStylePattern(style["strikethroughPattern"] as? String)
            view = AnyView(view.strikethrough(true, pattern: pat, color: col))
        }

        // Foreground
        if let fg = style["foreground"] as? String,
           let fgColor = Color(hex: fg) {
            view = AnyView(view.foregroundColor(fgColor))
        }

        // Typography extras
        if let ker = cg(style["kerning"]) {
            view = AnyView(view.kerning(ker))
        }
        if let track = cg(style["tracking"]) {
            view = AnyView(view.tracking(track))
        }
        if let base = cg(style["baselineOffset"]) {
            view = AnyView(view.baselineOffset(base))
        }

        // Layout modifiers
        if let align = style["textAlignment"] as? String {
            let ta: TextAlignment = {
                switch align.lowercased() {
                case "center":   return .center
                case "trailing": return .trailing
                default:         return .leading
                }
            }()
            view = AnyView(view.multilineTextAlignment(ta))
        } else if style["multiline"] as? Bool == true {
            view = AnyView(view.multilineTextAlignment(.leading))
        }
        if let ll = style["lineLimit"] as? Int {
            view = AnyView(view.lineLimit(ll > 0 ? ll : nil))
        }
        if let ls = cg(style["lineSpacing"]) {
            view = AnyView(view.lineSpacing(ls))
        }
        if let at = style["allowsTightening"] as? Bool {
            view = AnyView(view.allowsTightening(at))
        }
        if let msf = cg(style["minimumScaleFactor"]) {
            view = AnyView(view.minimumScaleFactor(msf))
        }
        if let tm = style["truncationMode"] as? String {
            let mode: Text.TruncationMode = {
                switch tm.lowercased() {
                case "head":   return .head
                case "middle": return .middle
                default:       return .tail
                }
            }()
            view = AnyView(view.truncationMode(mode))
        }

        // General View modifiers
        if let pad = cg(style["padding"]) {
            view = AnyView(view.padding(pad))
        } else {
            let t = cg(style["paddingTop"]) ?? 0
            let l = cg(style["paddingLeading"]) ?? 0
            let b = cg(style["paddingBottom"]) ?? 0
            let r = cg(style["paddingTrailing"]) ?? 0
            if t+l+b+r > 0 {
                view = AnyView(view.padding(EdgeInsets(top: t, leading: l, bottom: b, trailing: r)))
            }
        }
        if let bg = style["background"] as? String,
           let bgColor = Color(hex: bg) {
            view = AnyView(view.background(bgColor))
        }
        // Borda
        if let bc = style["borderColor"] as? String,
           let borderColor = Color(hex: bc),
           let bw = cg(style["borderWidth"]) {
            view = AnyView(
                view
                    .overlay(
                        RoundedRectangle(cornerRadius: cg(style["cornerRadius"]) ?? 0)
                            .stroke(borderColor, lineWidth: bw)
                    )
            )
        }
        if let op = style["opacity"] as? Double {
            view = AnyView(view.opacity(op))
        }
        if let cr = cg(style["cornerRadius"]), cr > 0 {
            view = AnyView(view.clipShape(RoundedRectangle(cornerRadius: cr)))
        }
        if let sr = cg(style["shadowRadius"]), sr > 0 {
            let sc = (style["shadowColor"] as? String).flatMap(Color.init(hex:)) ?? Color.black.opacity(0.33)
            let sx = cg(style["shadowX"]) ?? 0
            let sy = cg(style["shadowY"]) ?? 0
            view = AnyView(view.shadow(color: sc, radius: sr, x: sx, y: sy))
        }
        if style["width"] != nil || style["height"] != nil ||
           cg(style["maxWidth"]) != nil || cg(style["maxHeight"]) != nil {
            view = AnyView(
                view
                    .frame(
                        width: cg(style["width"]),
                        height: cg(style["height"]),
                        alignment: mapAlignment(style["frameAlignment"] as? String)
                    )
                    .frame(
                        maxWidth: cg(style["maxWidth"]),
                        maxHeight: cg(style["maxHeight"]),
                        alignment: mapAlignment(style["frameAlignment"] as? String)
                    )
            )
        }
        if let deg = style["rotationDegrees"] as? Double {
            view = AnyView(view.rotationEffect(.degrees(deg), anchor: mapUnitPoint(style["rotationAnchor"] as? String)))
        }
        if let sf = cg(style["scaleFactor"]) {
            view = AnyView(view.scaleEffect(sf, anchor: mapUnitPoint(style["scaleAnchor"] as? String)))
        }

        // special case: background+cornerRadius ordering—se já tiver feito antes, redevolva
        if let bg = style["background"] as? String,
           let bgColor = Color(hex: bg),
           let cr2 = cg(style["cornerRadius"]), cr2 > 0 {
            return AnyView(
                Text(value)
                    .padding(calculatePadding(from: style))
                    .background(bgColor)
                    .clipShape(RoundedRectangle(cornerRadius: cr2))
            )
        }

        return view
    }

    // 2️⃣ body só retorna o textContent
    var body: some View {
        textContent
    }

    // ——— Funções auxiliares (sem mudança de nome) ———

    private func mapFontWeight(_ weightString: String?) -> Font.Weight {
        switch weightString?.lowercased() {
        case "ultralight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "regular":    return .regular
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        case "black":      return .black
        default:             return .regular
        }
    }

    private func mapFontDesign(_ designString: String?) -> Font.Design {
        switch designString?.lowercased() {
        case "serif":      return .serif
        case "rounded":    return .rounded
        case "monospaced": return .monospaced
        default:            return .default
        }
    }

    private func mapLineStylePattern(_ patternString: String?) -> Text.LineStyle.Pattern {
        switch patternString?.lowercased() {
        case "dot":        return .dot
        case "dash":       return .dash
        case "dashdot":    return .dashDot
        case "dashdotdot": return .dashDotDot
        default:            return .solid
        }
    }

    private func mapAlignment(_ alignmentString: String?) -> Alignment {
        switch alignmentString?.lowercased() {
        case "center":        return .center
        case "leading":       return .leading
        case "trailing":      return .trailing
        case "topLeading":    return .topLeading
        case "topTrailing":   return .topTrailing
        case "bottomLeading": return .bottomLeading
        case "bottomTrailing":return .bottomTrailing
        default:               return .center
        }
    }

    private func mapUnitPoint(_ pointString: String?) -> UnitPoint {
        switch pointString?.lowercased() {
        case "top":           return .top
        case "bottom":        return .bottom
        case "leading":       return .leading
        case "trailing":      return .trailing
        case "topLeading":    return .topLeading
        case "topTrailing":   return .topTrailing
        case "bottomLeading": return .bottomLeading
        case "bottomTrailing":return .bottomTrailing
        default:               return .center
        }
    }

    private func calculatePadding(from style: [String: Any]) -> EdgeInsets {
        if let p = cg(style["padding"]) {
            return EdgeInsets(top: p, leading: p, bottom: p, trailing: p)
        } else {
            let t = cg(style["paddingTop"]) ?? 0
            let l = cg(style["paddingLeading"]) ?? 0
            let b = cg(style["paddingBottom"]) ?? 0
            let r = cg(style["paddingTrailing"]) ?? 0
            return EdgeInsets(top: t, leading: l, bottom: b, trailing: r)
        }
    }
    // Helper para converter Int/Double/CGFloat em CGFloat
    private func cg(_ any: Any?) -> CGFloat? {
        if let f = any as? CGFloat { return f }
        if let d = any as? Double  { return CGFloat(d) }
        if let i = any as? Int     { return CGFloat(i) }
        return nil
    }
}
