import SwiftUI

/// Chat with "Bit", the AI assistant that will later be connected to the university and Moodle.
/// UI only: replies are a fixed placeholder.
struct ChatView: View {
    @State private var messages = MockData.chat
    @State private var draft = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { MessageBubble(message: $0).id($0.id) }
                    }
                    .padding(16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) {
                    guard let last = messages.last?.id else { return }
                    withAnimation(.spring(duration: 0.35, bounce: 0)) { proxy.scrollTo(last, anchor: .bottom) }
                }
            }
            .safeAreaInset(edge: .bottom) { composer }
            .background(Theme.background)
            .navigationTitle("Bit")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(Theme.text)
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(MockData.suggestions, id: \.self) { suggestion in
                        Button(suggestion) { draft = suggestion; inputFocused = true }
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .glass(in: .capsule, interactive: true)
                            .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)

            HStack(spacing: 8) {
                TextField("Ask about your courses…", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .submitLabel(.send)
                    .onSubmit(send)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glass(in: .rect(cornerRadius: 22))

                Button(action: send) {
                    Image(systemName: "paperplane.fill")
                        .font(.body.bold())
                        .foregroundStyle(Theme.onAmber)
                        .frame(width: 44, height: 44)
                        .background(Theme.amber, in: .circle)
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send")
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 8)
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, fromUser: true))
        messages.append(ChatMessage(text: "I'm not connected to Moodle yet. This is a UI prototype.", fromUser: false))
        draft = ""
    }
}

private struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.fromUser { Spacer(minLength: 48) } else { RadarMark().frame(width: 26) }

            Text(message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(message.fromUser ? Theme.onAmber : Theme.text)
                .background(message.fromUser ? Theme.amber : Theme.surface,
                            in: UnevenRoundedRectangle(cornerRadii: message.fromUser
                                ? .init(topLeading: 18, bottomLeading: 18, bottomTrailing: 6, topTrailing: 18)
                                : .init(topLeading: 18, bottomLeading: 6, bottomTrailing: 18, topTrailing: 18)))

            if !message.fromUser { Spacer(minLength: 48) }
        }
    }
}

#Preview("Light") { ChatView() }
#Preview("Dark") { ChatView().preferredColorScheme(.dark) }
