//
//  LoginForm.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 17/11/25.
//
import SwiftUI

struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            let emailField = FormField(
                placeholder: "Email",
                text: $email,
                validators: [Validators.nonEmpty, Validators.email]
            )

            let passwordField = FormField(
                placeholder: "Password",
                text: $password,
                validators: [Validators.nonEmpty, Validators.minLength(6)]
            )

            emailField
            passwordField

            Button("Submit") {
                print("Submit pressed")
            }
            .disabled(!(emailField.isValid && passwordField.isValid))
            .padding(.top, 20)
        }
        .padding()
    }
}
