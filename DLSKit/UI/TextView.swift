import SwiftUI

struct TextView: View {
    let value: String
    let style: [String: Any]?

    var body: some View {
        // Começamos com o Text básico
        var textView = Text(value)

        // Aplicamos os estilos se o dicionário 'style' for fornecido
        if let style = style {

            // --- Modificadores Específicos de Texto ---

            // Fontes (Sistema e Customizadas)
            if let fontName = style["fontName"] as? String, let fontSize = style["fontSize"] as? CGFloat {
                // Fonte customizada pelo nome
                textView = textView.font(.custom(fontName, size: fontSize))
            } else if let font = style["font"] as? String {
                // Fontes de sistema pré-definidas
                switch font.lowercased() {
                case "largeTitle": textView = textView.font(.largeTitle)
                case "title": textView = textView.font(.title)
                case "title2": textView = textView.font(.title2)
                case "title3": textView = textView.font(.title3)
                case "headline": textView = textView.font(.headline)
                case "subheadline": textView = textView.font(.subheadline)
                case "body": textView = textView.font(.body)
                case "callout": textView = textView.font(.callout)
                case "footnote": textView = textView.font(.footnote)
                case "caption": textView = textView.font(.caption)
                case "caption2": textView = textView.font(.caption2)
                default:
                    // Tenta usar fonte de sistema com tamanho
                    if let fontSize = style["fontSize"] as? CGFloat {
                       let weight = mapFontWeight(style["fontWeight"] as? String)
                       let design = mapFontDesign(style["fontDesign"] as? String)
                       textView = textView.font(.system(size: fontSize, weight: weight, design: design))
                    }
                }
            } else if let fontSize = style["fontSize"] as? CGFloat {
                 // Fonte de sistema apenas com tamanho, peso e design
                 let weight = mapFontWeight(style["fontWeight"] as? String)
                 let design = mapFontDesign(style["fontDesign"] as? String)
                 textView = textView.font(.system(size: fontSize, weight: weight, design: design))
            }

            // Peso da Fonte (fontWeight)
            if let fontWeight = style["fontWeight"] as? String {
                textView = textView.fontWeight(mapFontWeight(fontWeight))
            }

            // Negrito (bold)
            if let isBold = style["bold"] as? Bool, isBold {
                textView = textView.bold()
            }

            // Itálico (italic)
            if let isItalic = style["italic"] as? Bool, isItalic {
                textView = textView.italic()
            }

            // Sublinhado (underline)
            if let isUnderline = style["underline"] as? Bool, isUnderline {
                let underlineColor = (style["underlineColor"] as? String).flatMap { Color(hex: $0) }
                let pattern = mapLineStylePattern(style["underlinePattern"] as? String)
                textView = textView.underline(true, pattern: pattern, color: underlineColor)
            }

            // Riscado (strikethrough)
            if let isStrikethrough = style["strikethrough"] as? Bool, isStrikethrough {
                let strikethroughColor = (style["strikethroughColor"] as? String).flatMap { Color(hex: $0) }
                 let pattern = mapLineStylePattern(style["strikethroughPattern"] as? String)
                textView = textView.strikethrough(true, pattern: pattern, color: strikethroughColor)
            }

            // Cor do Texto (foregroundColor)
            if let foreground = style["foreground"] as? String, let color = Color(hex: foreground) {
                textView = textView.foregroundColor(color)
            }

             // Kerning (Espaçamento entre caracteres específico)
            if let kerning = style["kerning"] as? CGFloat {
                textView = textView.kerning(kerning)
            }

            // Tracking (Espaçamento uniforme entre caracteres)
            if let tracking = style["tracking"] as? CGFloat {
                textView = textView.tracking(tracking)
            }

            // Deslocamento da Linha de Base (baselineOffset)
            if let baselineOffset = style["baselineOffset"] as? CGFloat {
                textView = textView.baselineOffset(baselineOffset)
            }

            // --- Modificadores de Layout de Texto ---

            // Alinhamento do Texto (multilineTextAlignment)
            if let alignment = style["textAlignment"] as? String {
                switch alignment.lowercased() {
                case "leading": textView = textView.multilineTextAlignment(.leading) as! Text
                case "center": textView = textView.multilineTextAlignment(.center) as! Text
                case "trailing": textView = textView.multilineTextAlignment(.trailing) as! Text
                default: textView = textView.multilineTextAlignment(.leading) as! Text // Padrão
                }
            } else if let multiline = style["multiline"] as? Bool, multiline {
                 // Mantém compatibilidade com o 'multiline' original, assumindo leading
                textView = textView.multilineTextAlignment(.leading) as! Text
            }


            // Limite de Linhas (lineLimit)
            if let lineLimit = style["lineLimit"] as? Int {
                 // lineLimit(nil) significa sem limite
                textView = textView.lineLimit(lineLimit > 0 ? lineLimit : nil) as! Text
            }

            // Espaçamento entre Linhas (lineSpacing)
            if let lineSpacing = style["lineSpacing"] as? CGFloat {
                textView = textView.lineSpacing(lineSpacing) as! Text
            }

            // Permitir "Apertar" o Texto (allowsTightening)
            if let allowsTightening = style["allowsTightening"] as? Bool {
                textView = textView.allowsTightening(allowsTightening) as! Text
            }

            // Fator Mínimo de Escala (minimumScaleFactor)
            if let minimumScaleFactor = style["minimumScaleFactor"] as? CGFloat {
                textView = textView.minimumScaleFactor(minimumScaleFactor) as! Text
            }

            // Modo de Truncamento (truncationMode)
            if let truncationMode = style["truncationMode"] as? String {
                switch truncationMode.lowercased() {
                case "head": textView = textView.truncationMode(.head) as! Text
                case "middle": textView = textView.truncationMode(.middle) as! Text
                case "tail": textView = textView.truncationMode(.tail) as! Text
                default: textView = textView.truncationMode(.tail) // Padrão
                }
            }

            // --- Modificadores Gerais de View (Aplicáveis ao Text) ---

            // Padding (Espaçamento Interno) - Simplificado para todas as bordas
            // Para padding individual (top, leading, etc.), seria necessário mais lógica
            if let padding = style["padding"] as? CGFloat {
                textView = textView.padding(padding) as! Text
            } else {
                 // Padding específico por lado
                 let paddingTop = style["paddingTop"] as? CGFloat ?? 0
                 let paddingLeading = style["paddingLeading"] as? CGFloat ?? 0
                 let paddingBottom = style["paddingBottom"] as? CGFloat ?? 0
                 let paddingTrailing = style["paddingTrailing"] as? CGFloat ?? 0
                 if paddingTop > 0 || paddingLeading > 0 || paddingBottom > 0 || paddingTrailing > 0 {
                     textView = textView.padding(EdgeInsets(top: paddingTop, leading: paddingLeading, bottom: paddingBottom, trailing: paddingTrailing))
                 }
            }


            // Fundo (background) - Pode ser uma cor ou outra View (simplificado para Cor)
            if let background = style["background"] as? String, let color = Color(hex: background) {
                // Usamos .background(Color) diretamente no Text,
                // mas para aplicar cornerRadius *depois* do background,
                // precisamos aplicar o background a uma forma ou view container.
                // Por simplicidade aqui, aplicamos direto no Text.
                // Para ter background com cantos arredondados, veja a seção .clipShape abaixo.
                 textView = textView.background(color)
            }

            // Borda (border)
            if let borderColor = style["borderColor"] as? String, let color = Color(hex: borderColor) {
                let borderWidth = style["borderWidth"] as? CGFloat ?? 1 // Padrão 1pt
                textView = textView.border(color, width: borderWidth)
            }

            // Opacidade (opacity)
            if let opacity = style["opacity"] as? Double {
                textView = textView.opacity(opacity)
            }

            // Raio do Canto (cornerRadius) - Requer clipping
            // IMPORTANTE: Para cornerRadius funcionar visualmente com background,
            // o background deve ser aplicado *antes* do .clipShape ou .cornerRadius.
            // A forma mais comum é aplicar o background a uma View container
            // ou usar .background(Shape().fill(color)).
            // O modificador .cornerRadius() está deprecated, use .clipShape(RoundedRectangle(cornerRadius:))
            if let cornerRadius = style["cornerRadius"] as? CGFloat, cornerRadius > 0 {
                 // Aplica o cornerRadius *depois* de outros modificadores como padding/background
                 // Nota: Isso cortará o próprio texto se não houver padding/background
                 // Para background com cantos arredondados, use .background + .clipShape
                 // Exemplo (requer refatoração para aplicar background ANTES):
                 // textView = textView.background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))

                 // Aplicação simples que corta a view:
                 textView = textView.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }


            // Sombra (shadow)
            if let shadowRadius = style["shadowRadius"] as? CGFloat, shadowRadius > 0 {
                let shadowColor = (style["shadowColor"] as? String).flatMap { Color(hex: $0) } ?? Color.black.opacity(0.33) // Cor padrão
                let shadowX = style["shadowX"] as? CGFloat ?? 0
                let shadowY = style["shadowY"] as? CGFloat ?? 0 // Padrão SwiftUI é um pouco abaixo
                 textView = textView.shadow(color: shadowColor, radius: shadowRadius, x: shadowX, y: shadowY)
            }

            // Frame (Tamanho e Alinhamento)
            let width = style["width"] as? CGFloat
            let height = style["height"] as? CGFloat
            let maxWidth = style["maxWidth"] as? CGFloat ?? .infinity
            let maxHeight = style["maxHeight"] as? CGFloat ?? .infinity
            let alignmentString = style["frameAlignment"] as? String

            if width != nil || height != nil || maxWidth != .infinity || maxHeight != .infinity {
                let alignment = mapAlignment(alignmentString)
                textView = textView.frame(width: width, height: height, alignment: alignment)
                                  .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: alignment)
            }

             // Rotação (rotationEffect)
             if let rotationDegrees = style["rotationDegrees"] as? Double {
                 let anchor = mapUnitPoint(style["rotationAnchor"] as? String)
                 textView = textView.rotationEffect(.degrees(rotationDegrees), anchor: anchor)
             }

             // Escala (scaleEffect)
             if let scaleFactor = style["scaleFactor"] as? CGFloat {
                 let anchor = mapUnitPoint(style["scaleAnchor"] as? String)
                 textView = textView.scaleEffect(scaleFactor, anchor: anchor)
             }
        }

        // Retorna a view Text configurada
        // Como Text é um struct, precisamos retornar a variável modificada.
        // No entanto, SwiftUI é mais eficiente se aplicarmos modificadores diretamente
        // em sequência, sem reatribuir a uma variável `var`.
        // A abordagem com `var textView` funciona, mas a forma idiomática seria:
        /*
         var body: some View {
             let baseText = Text(value)
             // Aplicar todos os modificadores em cadeia aqui, baseado no `style`
             // Ex: baseText.font(...).foregroundColor(...).padding(...) etc.
             // Isso requer uma estrutura diferente, talvez usando um ViewModifier.
             // Por simplicidade e para seguir o padrão inicial, manteremos a variável `var`.
         }
        */
        // A forma abaixo funciona porque `Text` e seus modificadores retornam `some View`
        let finalView = textView // Apenas para clareza, poderíamos retornar 'textView' diretamente

        // Tratamento especial para background com cornerRadius
        // Se ambos foram definidos, aplicamos de forma que funcione corretamente.
        if let style = style,
           let background = style["background"] as? String,
           let bgColor = Color(hex: background),
           let cornerRadius = style["cornerRadius"] as? CGFloat,
           cornerRadius > 0
        {
            // Removemos o background aplicado anteriormente (se houver)
            // e aplicamos background *dentro* de uma forma arredondada
             // Nota: Isso sobrescreve qualquer background aplicado anteriormente de forma simples
            return AnyView(
                textView
                    .padding(calculatePadding(from: style)) // Reaplica padding se necessário para ficar dentro do background
                    .background(bgColor)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    // Outros modificadores que devem vir *depois* do clip (ex: shadow, border no clip)
                    // A ordem aqui pode precisar de ajustes finos dependendo do efeito desejado.
            )

        } else {
             // Retorna a view como foi modificada até agora
             return AnyView(finalView)
        }
    }

    // --- Funções Auxiliares para Mapeamento ---

    private func mapFontWeight(_ weightString: String?) -> Font.Weight {
        switch weightString?.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .regular // Padrão
        }
    }

    private func mapFontDesign(_ designString: String?) -> Font.Design {
        switch designString?.lowercased() {
        case "default": return .default
        case "serif": return .serif
        case "rounded": return .rounded
        case "monospaced": return .monospaced
        default: return .default // Padrão
        }
    }

     private func mapLineStylePattern(_ patternString: String?) -> Text.LineStyle.Pattern {
        switch patternString?.lowercased() {
        case "solid": return .solid
        case "dot": return .dot
        case "dash": return .dash
        case "dashdot": return .dashDot
        case "dashdotdot": return .dashDotDot
        default: return .solid // Padrão
        }
    }

    private func mapAlignment(_ alignmentString: String?) -> Alignment {
        switch alignmentString?.lowercased() {
        case "center": return .center
        case "leading": return .leading
        case "trailing": return .trailing
        case "top": return .top
        case "bottom": return .bottom
        case "topleading": return .topLeading
        case "toptrailing": return .topTrailing
        case "bottomleading": return .bottomLeading
        case "bottomtrailing": return .bottomTrailing
        default: return .center // Padrão
        }
    }

    private func mapUnitPoint(_ pointString: String?) -> UnitPoint {
         switch pointString?.lowercased() {
         case "zero": return .zero
         case "center": return .center
         case "leading": return .leading
         case "trailing": return .trailing
         case "top": return .top
         case "bottom": return .bottom
         case "topLeading": return .topLeading
         case "topTrailing": return .topTrailing
         case "bottomLeading": return .bottomLeading
         case "bottomTrailing": return .bottomTrailing
         default: return .center // Padrão
         }
    }

     // Helper para calcular padding para o caso especial background+cornerRadius
     private func calculatePadding(from style: [String: Any]) -> EdgeInsets {
         if let padding = style["padding"] as? CGFloat {
             return EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
         } else {
             let paddingTop = style["paddingTop"] as? CGFloat ?? 0
             let paddingLeading = style["paddingLeading"] as? CGFloat ?? 0
             let paddingBottom = style["paddingBottom"] as? CGFloat ?? 0
             let paddingTrailing = style["paddingTrailing"] as? CGFloat ?? 0
             return EdgeInsets(top: paddingTop, leading: paddingLeading, bottom: paddingBottom, trailing: paddingTrailing)
         }
     }
}


// --- Exemplo de Uso ---

struct ContentView_TextViewExample: View {
    let myStyle: [String: Any] = [
        "font": "title2", // Fonte de sistema
        "fontWeight": "semibold",
        "foreground": "#FFFFFF", // Branco
        "background": "#007AFF", // Azul Apple
        "padding": 15,
        "cornerRadius": 10,
        "textAlignment": "center",
        "lineLimit": 2,
        "minimumScaleFactor": 0.8,
        "shadowColor": "#000000", // Preto
        "shadowRadius": 5,
        "shadowY": 3,
//        "strikethrough": true,
//        "strikethroughColor": "#FF0000",
//        "width": 200,
//        "height": 100,
//        "frameAlignment": "center",
//        "rotationDegrees": -10,
//        "scaleFactor": 0.9
    ]

     let anotherStyle: [String: Any] = [
         "fontName": "HelveticaNeue-Italic", // Fonte customizada por nome
         "fontSize": 18,
         "foreground": "#333333", // Cinza escuro
         "lineSpacing": 8,
         "allowsTightening": true,
         "truncationMode": "tail",
         "paddingLeading": 20,
         "paddingTrailing": 20,
         "borderWidth": 2,
         "borderColor": "#CCCCCC" // Cinza claro
     ]

    var body: some View {
        VStack(spacing: 20) {
            TextView(value: "Olá Mundo Estilizado!", style: myStyle)
                .frame(width: 250) // Frame externo para limitar o tamanho no exemplo

            TextView(value: "Este é um texto mais longo que pode precisar ser truncado ou quebrar linha, dependendo do espaço disponível e das configurações de estilo como lineLimit.", style: anotherStyle)

             TextView(value: "Simples", style: ["foreground": "FF00FF"]) // Apenas cor
        }
        .padding()
    }
}

struct ContentView_TextViewExample_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_TextViewExample()
    }
}
