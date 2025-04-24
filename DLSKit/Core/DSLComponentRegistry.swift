import SwiftUICore
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
        if let renderer = registry[type] {
            return renderer(props, interpreter, router)
        }
        return AnyView(EmptyView())
    }

    private func registerDefaults() {
        register(type: "text") { props, _, _ in
            let value = props["value"] as? String ?? ""
            let style = props["style"] as? [String: Any]
            return AnyView(TextView(value: value, style: style))
        }

        register(type: "input") { props, interpreter, _ in
            let bind = props["bind"] as? String ?? ""
            let style = props["style"] as? [String: Any]
            return AnyView(InputView(bindingKey: bind, style: style, interpreter: interpreter))
        }

        register(type: "button") { props, interpreter, router in
            let label = props["label"] as? String ?? "Button"
            let action = props["onTap"]
            let style = props["style"] as? [String: Any]
            return AnyView(ButtonView(label: label, action: action, style: style, interpreter: interpreter, router: router))
        }
    }
}
