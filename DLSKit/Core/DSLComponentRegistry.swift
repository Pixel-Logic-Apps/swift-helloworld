import SwiftUI

class DSLComponentRegistry {
    typealias Renderer = (_ props: [String: Any], _ interpreter: DSLInterpreter, _ router: DSLRouter) -> AnyView

    private var registry: [String: Renderer] = [:]
    static let shared = DSLComponentRegistry()
    
    private init() {
        registerDefaults()
    }

    func register(type: String, renderer: @escaping Renderer) {
        registry[type] = renderer
    }

    func resolve(type: String, props: [String: Any], interpreter: DSLInterpreter, router: DSLRouter) -> AnyView {
        return registry[type]?(props, interpreter, router) ?? AnyView(EmptyView())
    }

    private func registerDefaults() {
        // 1) Text
        register(type: "text") { props, interpreter, _ in
            let raw = props["value"] as Any
            let value = interpreter.evaluate(raw) as? String ?? ""
            let style = props["style"] as? [String:Any]
            return AnyView(TextView(value: value, style: style))
        }

        // 2) Input
        register(type: "input") { props, interpreter, _ in
            let placeholder = props["placeholder"] as? String ?? ""
            let bindKey     = props["bind"]        as? String ?? ""
            let style       = props["style"]       as? [String: Any]
            let binding = Binding<String>(
                get: { interpreter.context.resolve(bindKey) as? String ?? "" },
                set: { interpreter.context.set(bindKey, value: $0) }
            )
            return AnyView(
                InputView(
                    placeholder: placeholder,
                    text: binding,
                    style: style
                )
            )
        }

        // 3) Button
        register(type: "button") { props, interpreter, router in
            let value     = props["label"]   as? String       ?? "Button"
            let style     = props["style"]   as? [String: Any]
            let onTapExpr = props["onTap"]
            return AnyView(
                ButtonView(
                    value: value,
                    style: style,
                    onTap: {
                        print("👉 botão pressionado!")
                        guard let expr = onTapExpr else { return }
                        Task {
                            print("👉 executando \(expr)")
                            await interpreter.execute(expr, router: router)
                        }
                    }
                )
            )
        }

        // 4) List
        register(type: "list") { props, interpreter, router in
            // 4.1) Extrai e avalia array de dicionários
            let raw = props["items"] as Any
            print("DEBUG rawItems:", raw)
            let items = interpreter.evaluate(raw) as? [[String:Any]] ?? []
            print("DEBUG items.count", items.count)
            let style    = props["style"]         as? [String:Any]
            let rowComps = props["rowComponents"] as? [[String:Any]] ?? []

            // 4.2) Cria um DSLRowView para cada linha
            let rows = items.map { rowDict in
                DSLRowView(
                    rowData:     rowDict,
                    rowComps:    rowComps,
                    baseContext: interpreter.context.data,
                    router:      router
                )
            }

            // 4.3) Renderiza tudo de forma puramente declarativa
            return AnyView(
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { _, rowView in
                            rowView
                        }
                    }
                    .padding()
                    .background(Color(hex: style?["background"] as? String ?? "#FFFFFF"))
                }
            )
        }
    }
}

/// Um View que representa cada linha da lista, isolando toda lógica imperativa
struct DSLRowView: View {
    let rowData:    [String: Any]
    let rowComps:   [[String: Any]]
    let baseContext: [String: Any]
    let router:     DSLRouter

    @State private var interp: DSLInterpreter

    init(
        rowData:    [String: Any],
        rowComps:   [[String: Any]],
        baseContext: [String: Any],
        router:     DSLRouter
    ) {
        self.rowData = rowData
        self.rowComps = rowComps
        self.baseContext = baseContext
        self.router = router

        // Prepara um interpreter com os dados herdados + os da linha
        let di = DSLInterpreter()
        di.context.data = baseContext
        rowData.forEach { di.context.data[$0] = $1 }
        _interp = State(wrappedValue: di)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(rowComps.enumerated()), id: \.offset) { _, compProps in
                let merged = compProps.merging(rowData) { _, new in new }
                DSLComponentRegistry
                    .shared
                    .resolve(type: merged["type"] as! String,
                             props: merged,
                             interpreter: interp,
                             router: router)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}
