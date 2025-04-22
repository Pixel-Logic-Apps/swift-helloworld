import SwiftUI
import AnyCodable

struct DSLViewRenderer: View {
    let screen: DSLScreen
    @ObservedObject var router: DSLRouter
    @ObservedObject var interpreter: DSLInterpreter
    @State private var executed = false

    var body: some View {
        VStack(spacing: 16) {
            componentsView
        }
        .padding()
        .onAppear(perform: performOnAppearLogic)
        .sheet(isPresented: sheetBinding, content: modalView)
        .navigationTitle(screen.navigationBar?.title ?? "")
        .navigationBarTitleDisplayMode(navBarDisplayMode)
        .toolbar(content: toolbarContent)
    }

    // MARK: - Subviews e Computed Properties

    private var componentsView: some View {
        ForEach(Array(screen.components.enumerated()), id: \.offset) { index, componentDict in
            let component = componentDict.mapValues { $0.value }
            if shouldShow(component) {
                renderComponent(component)
            }
        }

    }

    private func performOnAppearLogic() {
        guard !executed, let logic = screen.onAppearLogic else { return }
        executed = true
        Task {
            await interpreter.execute(logic, router: router)
        }
    }

    private var sheetBinding: Binding<Bool> {
        Binding(
            get: { !router.modals.isEmpty },
            set: { if !$0 { router.dismissModal() } }
        )
    }

    @ViewBuilder
    private func modalView() -> some View {
        if let modal = router.modals.last {
            DSLViewRenderer(screen: modal, router: router, interpreter: interpreter)
        }
    }

    private var navBarDisplayMode: NavigationBarItem.TitleDisplayMode {
        (screen.navigationBar?.displayMode == "large") ? .large : .inline
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        if let trailing = screen.navigationBar?.trailingButton {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(trailing.label) {
                    if let action = trailing.action {
                        Task {
                            await interpreter.execute(action, router: router)
                        }
                    }
                }
            }
        }
    }

    
    
    @ViewBuilder
    func renderComponent(_ component: [String: Any]) -> some View {
        switch component["type"] as? String {
        case "text":
            let value = interpreter.evaluate(component["value"] ?? "") as? String ?? ""
            Text(value)

        case "input":
            let bindingKey = component["bind"] as? String ?? ""
            TextField("", text: Binding(
                get: { interpreter.context.resolve(bindingKey) as? String ?? "" },
                set: { interpreter.context.set(bindingKey, value: $0) }
            ))
            .textFieldStyle(.roundedBorder)

        case "button":
            let label = component["label"] as? String ?? "Botão"
            Button(label) {
                if let onTap = component["onTap"] {
                    Task {
                        await interpreter.execute(onTap, router: router)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

        default:
            EmptyView()
        }
    }

    func shouldShow(_ component: [String: Any]) -> Bool {
        if let condition = component["visibleIf"] {
            return interpreter.evaluate(condition) as? Bool ?? true
        }
        return true
    }
}
