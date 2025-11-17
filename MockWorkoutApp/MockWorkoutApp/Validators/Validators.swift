//
//  Validators.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 17/11/25.
//

import Foundation

typealias Validator = (String) -> String?

struct Validators {
    static let nonEmpty: Validator = { text in
        text.isEmpty ? "Cannot be empty" : nil
    }

    static let email: Validator = { text in
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegex).evaluate(with: text) ? nil : "Invalid email"
    }

    static let minLength = { (length: Int) -> Validator in
        { text in
            text.count < length ? "Minimum \(length) characters" : nil
        }
    }

    static func multi(_ validators: [Validator]) -> Validator {
        { text in
            for v in validators {
                if let error = v(text) { return error }
            }
            return nil
        }
    }
}
