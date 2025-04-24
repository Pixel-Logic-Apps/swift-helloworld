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
    
    // 1️⃣ Marque com @ViewBuilder
    @ViewBuilder
    private var componentsView: some View {
        ForEach(Array(screen.components.enumerated()), id: \.offset) { _, raw in
            let props = raw.mapValues { $0.value }
            if shouldShow(props) {
                DSLComponentRegistry.shared
                    .resolve(
                      type: props["type"] as! String,
                      props: props,
                      interpreter: interpreter,
                      router: router
                    )
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
        let type = component["type"] as? String ?? ""
        DSLComponentRegistry.shared.resolve(
            type: type,
            props: component,
            interpreter: interpreter,
            router: router
        )
    }

    func shouldShow(_ component: [String: Any]) -> Bool {
        if let condition = component["visibleIf"] {
            return interpreter.evaluate(condition) as? Bool ?? true
        }
        return true
    }
}
