import SwiftUI
//
//@main
//struct App: SwiftUI.App{
//    @StateObject var router = DSLRouter()
//    @StateObject var interpreter = DSLInterpreter()
//    @State private var isReady = false
//    
//    func loadScreensFromJSON() -> [DSLScreen] {
//        guard let url = Bundle.main.url(forResource: "dsl_screens", withExtension: "json"),
//              let data = try? Data(contentsOf: url),
//              let screens = try? JSONDecoder().decode([DSLScreen].self, from: data) else {
//            return []
//        }
//        return screens
//    }
//    
//    var body: some Scene {
//        WindowGroup{
//            Group{
//                if isReady, let screen = router.currentScreen{
//                    NavigationStack{
//                        DSLViewRenderer(screen:screen, router:router, interpreter:interpreter)
//                    }
//                }else{
//                    Color.clear //mantém splash nativo visível
//                        .onAppear{
//                            Task {
//                                interpreter.context.data["form"] = ["nome": ""]
//                                let screens = loadScreensFromJSON()
//                                router.preload(screens: screens)
//                                router.navigate(to: "telaA")
//                                isReady = true
//                            }
//                        }
//                }
//            }
//        }
//    }
//}

@main
struct App: SwiftUI.App {
    @StateObject var router = DSLRouter()
    @StateObject var interpreter = DSLInterpreter()
    @State private var isReady = false
    
    func loadScreensFromJSON() -> [DSLScreen] {
        guard let url = Bundle.main.url(forResource: "dsl_screens", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let screens = try? JSONDecoder().decode([DSLScreen].self, from: data) else {
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
                            DSLViewRenderer(screen: screen, router: router, interpreter: interpreter)
                                .navigationDestination(for: DSLScreen.self) { screen in
                                    DSLViewRenderer(screen: screen, router: router, interpreter: interpreter)
                                }
                        }


                    }
                } else {
                    // Mantém splash nativo enquanto carrega
                    Color.clear
                        .onAppear {
                            Task {
                                interpreter.context.data["form"] = ["nome": ""]
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
