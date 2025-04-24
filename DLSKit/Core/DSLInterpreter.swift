import Foundation
import SwiftUICore
import Combine
import UIKit

class DSLInterpreter: ObservableObject {
    // 1) Contexto continua um ObservableObject, mas aqui é só var
    var context = DSLContext()
    
    // 2) Precisamos desse publisher para repassar mudanças do context
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Sempre que o context anunciar objectWillChange,
        // façamos o interpreter também anunciar, para as Views reagirem.
        context.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func evaluate(_ expr: Any) -> Any? {
        // 1) Strings com interpolation de variáveis ($var.path)
        if let str = expr as? String, str.contains("$") {
            let pattern = #"\$([a-zA-Z0-9_.]+)"#
            let regex   = try? NSRegularExpression(pattern: pattern)
            let range   = NSRange(str.startIndex..., in: str)
            var result  = str
            regex?.enumerateMatches(in: str, options: [], range: range) { match, _, _ in
                guard
                    let m         = match,
                    let pathRange = Range(m.range(at: 1), in: result)
                else { return }
                let path        = String(result[pathRange])
                let replacement = (self.context.resolve(path) as? String) ?? ""
                if let fullRange = Range(m.range(at:0), in: result) {
                    result.replaceSubrange(fullRange, with: replacement)
                }
            }
            return result
        }

        // 2) Dicionários — trata "var", "concat" e depois recursivamente cada campo
        if let dict = expr as? [String: Any] {
            // 2a) variável simples
            if let variable = dict["var"] as? String {
                return context.resolve(variable)
            }
            // 2b) concatenação de strings
            if let concat = dict["concat"] as? [Any] {
                return concat
                    .compactMap { evaluate($0) as? String }
                    .joined()
            }
            // 2c) deep-evaluate: percorre cada chave e avalia recursivamente
            var out: [String: Any] = [:]
            for (k, v) in dict {
                if let ev = evaluate(v) {
                    out[k] = ev
                }
            }
            return out
        }

        // 3) Arrays — avalia cada elemento
        if let arr = expr as? [Any] {
            return arr.compactMap { evaluate($0) }
        }

        // 4) Qualquer outro valor (Int, Double, Bool, etc.)
        return expr
    }


    func execute(_ node: Any, router: DSLRouter? = nil) async {
        guard let dict = node as? [String: Any] else { return }
        
        // 1) Detecta o "append"
        if let append = dict["append"] as? [String: Any],
           let variable = append["var"] as? String,
           let rawValue = append["value"] {
            
            // 2) Avalia o valor e exige um dicionário [String:Any]
            guard let newEntry = evaluate(rawValue) as? [String: Any] else {
                print("⚠️ append: valor não é dicionário —", evaluate(rawValue) as Any)
                return
            }
            
            // 3) Puxa o array atual de dicionários ou inicializa vazio
            var arr = (context.resolve(variable) as? [[String: Any]]) ?? []
            
            // 4) Insere o novo dicionário
            arr.append(newEntry)
            
            // 5) Atualiza o contexto
            context.set(variable, value: arr)
            print("✅ appendeu dict:", newEntry, "→ lista agora:", arr)
            return
        }


        if let sequence = dict["sequence"] as? [Any] {
            for step in sequence {
                await execute(step, router: router)
            }
            return
        }

        if let set = dict["set"] as? [String: Any],
           let variable = set["var"] as? String,
           let value = set["value"] {
            context.set(variable, value: evaluate(value) ?? NSNull())
            return
        }

        if let action = dict["action"] as? String {
            switch action {
            case "navigate":
                if let screenId = (dict["params"] as? [String: Any])?["screen"] as? String {
                    DispatchQueue.main.async {
                        router?.navigate(to: screenId)
                    }
                }
            case "navigateBack":
                DispatchQueue.main.async {
                    router?.goBack()
                }
            case "showAlert":
                let msg = evaluate((dict["params"] as? [String: Any])?["message"] ?? "") as? String ?? ""
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Alerta", message: msg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
            default:
                break
            }
        }

    }
}

class DSLContext: ObservableObject {
    @Published var data: [String: Any] = [:]

    func resolve(_ path: String) -> Any? {
        let keys = path.split(separator: ".").map(String.init)
        return keys.reduce(data as Any?) { acc, key in
            if let dict = acc as? [String: Any] {
                return dict[key]
            }
            return nil
        }
    }

    func set(_ path: String, value: Any) {
        let keys = path.split(separator: ".").map(String.init)
        guard !keys.isEmpty else { return }
        setValue(&data, keys: keys, value: value)
    }

    private func setValue(_ dict: inout [String: Any], keys: [String], value: Any) {
        guard let firstKey = keys.first else { return }

        if keys.count == 1 {
            dict[firstKey] = value
        } else {
            var childDict = dict[firstKey] as? [String: Any] ?? [:]
            setValue(&childDict, keys: Array(keys.dropFirst()), value: value)
            dict[firstKey] = childDict
        }
    }

}
