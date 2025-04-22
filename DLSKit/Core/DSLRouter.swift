//import SwiftUI
//
//class DSLRouter: ObservableObject {
//    @Published var currentScreen: DSLScreen?
//    @Published var screenStack: [DSLScreen] = []
//    @Published var screenCache: [String: DSLScreen] = [:]
//    @Published var modals: [DSLScreen] = []
//
//    func preload(screens: [DSLScreen]) {
//        for screen in screens {
//            screenCache[screen.id] = screen
//        }
//    }
//
//    func navigate(to screenId: String) {
//        if let screen = screenCache[screenId] {
//            screenStack.append(screen)
//            currentScreen = screen
//        }
//    }
//
//    func goBack() {
//        _ = screenStack.popLast()
//        currentScreen = screenStack.last
//    }
//
//    func presentModal(screenId: String) {
//        if let screen = screenCache[screenId] {
//            modals.append(screen)
//        }
//    }
//
//    func dismissModal() {
//        _ = modals.popLast()
//    }
//}

import SwiftUI

class DSLRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var modals: [DSLScreen] = []
    @Published var screenCache: [String: DSLScreen] = [:]

    /// Pré-carrega todas as telas vindas do JSON
    func preload(screens: [DSLScreen]) {
        for screen in screens {
            screenCache[screen.id] = screen
        }
    }

    /// Navega para uma tela registrada pelo ID
    func navigate(to screenId: String) {
        if let screen = screenCache[screenId] {
            path.append(screen)
        }
    }

    /// Volta para a tela anterior na pilha
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    /// Volta para a tela raiz
    func reset(to screenId: String) {
        path.removeLast(path.count)
        if let screen = screenCache[screenId] {
            path.append(screen)
        }
    }
    
    func push(_ screen: DSLScreen) {
        modals.append(screen)
        path.append(screen)
    }

    func pop() {
        modals.removeLast()
        path.removeLast()
    }

    var currentScreen: DSLScreen? {
        modals.last
    }
    
        func dismissModal() {
            _ = modals.popLast()
        }
}
