import SwiftUI

struct DismissPromptField: View {
    @Binding var text: String
    let onSubmit: () -> Void
    let isFocused: FocusState<Bool>.Binding

    private let cornerRadius: CGFloat = 10
    private let fieldWidth: CGFloat = 220
    private let fieldHeight: CGFloat = 44

    var body: some View {
        VStack(spacing: 8) {
            Text("Type **inshallah** to dismiss")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.1))

                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)

                TextField("", text: $text)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(height: fieldHeight)
                    .focused(isFocused)
                    .onSubmit(onSubmit)
            }
            .frame(width: fieldWidth, height: fieldHeight)
            .contentShape(.rect(cornerRadius: cornerRadius))
            .overlay {
                Button {
                    isFocused.wrappedValue = true
                } label: {
                    Color.clear
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
        }
    }
}
