//
//  OTPCountdownView.swift
//  MockWorkoutApp
//
//  Created by nanghuy on 24/11/25.
//
import SwiftUI

// MARK: - View
struct OTPCountdownView: View {

    @StateObject private var vm = OTPTimelineViewModel()

    var body: some View {
        VStack(spacing: 20) {

            // Countdown timer updated every second
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let remaining = vm.remainingSeconds(from: context.date)

                Text("\(remaining)s")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(remaining == 0 ? .red : .green)
                    .animation(.easeInOut, value: remaining)
            }
            .frame(height: 60)

            // Error message (optional)
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // Resend button
            Button {
                Task {
                    await vm.resendCode()
                }
            } label: {
                HStack {
                    if vm.isLoading {
                        ProgressView()     // Loading spinner
                    }
                    Text("Resend Code")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isExpired ? Color.accentColor : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            // Disable button when not expired OR loading
            .disabled(!vm.isExpired || vm.isLoading)
            .padding(.horizontal)
        }
        .padding()
    }
}


// MARK: - Preview
struct OTPCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        OTPCountdownView()
    }
}
