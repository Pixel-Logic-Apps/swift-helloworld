import SwiftUI

struct ListView<Item: Identifiable,Row:View>: View {
    let items: [Item]
    let style: [String: Any]?
    let rowContent: (Item) -> Row

    var body: some View {
        List {
          Section(header: Text("Título")) {
            ForEach(items) { item in
              rowContent(item)
            }
          }
        }
        .listStyle(InsetGroupedListStyle())
        .background(listBackground())
        .environment(\.defaultMinListRowHeight, minRowHeight())
    }

    // MARK: — Helpers de estilo

    private func listStyle() -> any ListStyle {
        switch style?["listStyle"] as? String {
        case "plain":           return PlainListStyle()
        case "inset":           return InsetListStyle()
        case "insetGrouped":    return InsetGroupedListStyle()
        case "grouped":         return GroupedListStyle()
        case "sidebar":         return SidebarListStyle()
        default:                return DefaultListStyle()
        }
    }

    private func listBackground() -> some View {
        if let hex = style?["background"] as? String,
           let color = Color(hex: hex) {
            return AnyView(color.ignoresSafeArea())
        }
        return AnyView(EmptyView())
    }

    private func minRowHeight() -> CGFloat {
        (style?["minRowHeight"] as? CGFloat) ?? 44
    }

    private func rowStyle() -> AnyViewModifier {
        let bgHex = style?["rowBackground"] as? String
        let bgColor = bgHex.flatMap(Color.init(hex:)) ?? Color.clear

        let sepHidden = (style?["separatorHidden"] as? Bool) ?? false
        let sepTint = (style?["separatorTint"] as? String).flatMap(Color.init(hex:))

        let inset = cg(style?["rowInset"]) ?? 0

        return AnyViewModifier { content in
            AnyView(
                content
                    .listRowBackground(bgColor)
                    .listRowSeparator(sepHidden ? .hidden : .visible)
                    .listRowSeparatorTint(sepTint)
                    .listRowInsets(EdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset))
            )
        }
    }


    private func bindingSelection() -> Binding<Set<Item.ID>>? {
        // Se for configurado um estilo de seleção no dicionário:
        guard let selected = style?["selection"] as? [Item.ID] else { return nil }
        return Binding(
            get: { Set(selected) },
            set: { _ in /* opcional: atualizar o estado */ }
        )
    }

    // MARK: — Utilitário para números
    private func cg(_ any: Any?) -> CGFloat? {
        if let f = any as? CGFloat { return f }
        if let d = any as? Double  { return CGFloat(d) }
        if let i = any as? Int     { return CGFloat(i) }
        return nil
    }
}

/// Um ViewModifier inline, pois não usamos mais structs auxiliares
struct AnyViewModifier: ViewModifier {
    let build: (AnyView) -> AnyView
    func body(content: Content) -> some View {
        build(AnyView(content))
    }
}
