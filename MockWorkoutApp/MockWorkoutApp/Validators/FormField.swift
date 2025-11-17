//
//  FormField.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 17/11/25.
//

import SwiftUI

struct FormField: View {
    let placeholder: String
    @Binding var text: String
    var validators: [Validator] = []

    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { _ in
                    validate()
                }

            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }

    func validate() {
        for validator in validators {
            if let e = validator(text) {
                error = e
                return
            }
        }
        error = nil
    }

    var isValid: Bool {
        validate()
        return error == nil
    }
}
