import Foundation
import UIKit

class DSLInterpreter: ObservableObject {
    var context = DSLContext()

    func evaluate(_ expr: Any) -> Any? {
        if let str = expr as? String, str.contains("$") {
            let pattern = #"\$([a-zA-Z0-9_.]+)"#
            let regex = try? NSRegularExpression(pattern: pattern, options: [])

            let range = NSRange(str.startIndex..., in: str)
            var result = str

            regex?.enumerateMatches(in: str, options: [], range: range) { match, _, _ in
                if let matchRange = match?.range(at: 0),
                   let pathRange = match?.range(at: 1),
                   let matchSubstring = Range(matchRange, in: result),
                   let pathSubstring = Range(pathRange, in: result) {
                    
                    let path = String(result[pathSubstring])
                    let replacement = self.context.resolve(path) as? String ?? ""
                    result.replaceSubrange(matchSubstring, with: replacement)
                }
            }

            return result
        }

        if let dict = expr as? [String: Any] {
            if let variable = dict["var"] as? String {
                return context.resolve(variable)
            }
            if let concat = dict["concat"] as? [Any] {
                return concat.map { evaluate($0) as? String ?? "" }.joined()
            }
        }
        return expr
    }

    func execute(_ node: Any, router: DSLRouter? = nil) async {
        guard let dict = node as? [String: Any] else { return }

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

class DSLContext {
    var data: [String: Any] = [:]

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
        var keys = path.split(separator: ".").map(String.init)
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
