import SwiftUI

@main
struct App: SwiftUI.App {
    @StateObject var router = DSLRouter()
    @StateObject var interpreter = DSLInterpreter()
    @State private var isReady = false
    
    func loadScreensFromJSON() -> [DSLScreen] {
        guard let url = Bundle.main.url(forResource: "dsl_screens", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let screens = try? JSONDecoder().decode([DSLScreen].self, from: data)
        else {
            return []
        }
        return screens
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isReady {
                    NavigationStack(path: $router.path) {
                        // Raiz da navegação (tela inicial)
                        if let screen = router.currentScreen ?? router.screenCache["telaA"] {
                            DSLViewRenderer(screen: screen,
                                            router: router,
                                            interpreter: interpreter)
                                .navigationDestination(for: DSLScreen.self) { screen in
                                    DSLViewRenderer(screen: screen,
                                                    router: router,
                                                    interpreter: interpreter)
                                }
                        }
                    }
                } else {
                    // Mantém splash nativo enquanto carrega
                    Color.clear
                        .onAppear {
                            Task {
                                // Inicializa o registry e registra os defaults
                                _ = DSLComponentRegistry.shared
                                
                                // Preenche o ctx e pré-carrega telas
                                interpreter.context.data["form"] = [
                                    "nome":  "",
                                    "lista": [[String:Any]]()  // array vazio
                                ]
                                let screens = loadScreensFromJSON()
                                router.preload(screens: screens)

                                isReady = true
                            }
                        }
                }
            }
        }
    }
}

