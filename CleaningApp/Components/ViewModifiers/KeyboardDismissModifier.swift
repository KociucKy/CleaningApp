import SwiftUI

// MARK: - KeyboardDismissModifier

struct KeyboardDismissModifier: ViewModifier {
    // MARK: - Properties

    private let dismiss: () -> Void

    // MARK: - Init

    init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button(action: dismiss) {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.body)
                            .imageScale(.medium)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("common.action.done"))
                }
            }
            .onDisappear(perform: dismiss)
    }
}

// MARK: - View

extension View {
    func dismissesKeyboard(using dismiss: @escaping () -> Void) -> some View {
        modifier(KeyboardDismissModifier(dismiss: dismiss))
    }
}
