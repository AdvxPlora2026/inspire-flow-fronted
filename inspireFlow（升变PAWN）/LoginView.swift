import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: AppSession
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .creator
    @State private var isCreatingAccount = false
    @State private var hasAttemptedSubmit = false
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.027, blue: 0.032)
                .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 360, height: 360)
                .blur(radius: 80)
                .offset(x: 170, y: -310)
                .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    brandHeader
                    rolePicker
                    credentialsForm
                    primaryButton
                    modeButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 44)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title2.weight(.bold))
                .foregroundStyle(.black)
                .frame(width: 48, height: 48)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12))

            Text(isCreatingAccount ? "创建你的工作空间" : "欢迎回来")
                .font(.system(size: 34, weight: .bold, design: .rounded))

            Text("登录后继续管理灵感、商业委托和创作交付。")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你的身份")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(UserRole.allCases) { role in
                    Button {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                            selectedRole = role
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: role.symbol)
                                .font(.headline)

                            Text(role.title)
                                .font(.subheadline.weight(.bold))

                            Text(role.detail)
                                .font(.caption)
                                .foregroundStyle(selectedRole == role ? Color.black.opacity(0.62) : .secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundStyle(selectedRole == role ? Color.black : Color.white)
                        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
                        .padding(14)
                        .background(
                            selectedRole == role ? Color.white : Color.white.opacity(0.055),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.white.opacity(selectedRole == role ? 0 : 0.12))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var credentialsForm: some View {
        VStack(spacing: 12) {
            LoginField(
                title: "邮箱",
                symbol: "envelope.fill",
                text: $email,
                contentType: .emailAddress,
                isSecure: false
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            LoginField(
                title: "密码（至少 6 位）",
                symbol: "lock.fill",
                text: $password,
                contentType: isCreatingAccount ? .newPassword : .password,
                isSecure: true
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit(submit)

            if hasAttemptedSubmit && !isValid {
                Label("请输入有效邮箱和至少 6 位密码", systemImage: "exclamationmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var primaryButton: some View {
        Button(action: submit) {
            HStack {
                Text(isCreatingAccount ? "创建并进入" : "登录")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 18)
            .frame(height: 54)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private var modeButton: some View {
        Button {
            isCreatingAccount.toggle()
            hasAttemptedSubmit = false
        } label: {
            Text(isCreatingAccount ? "已有账号？登录" : "还没有账号？创建账号")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.white)
    }

    private var isValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    private func submit() {
        hasAttemptedSubmit = true
        guard isValid else { return }
        focusedField = nil
        if isCreatingAccount {
            session.register(email: email, role: selectedRole)
        } else {
            session.signIn(email: email, role: selectedRole)
        }
    }

    private enum Field {
        case email
        case password
    }
}

private struct LoginField: View {
    let title: String
    let symbol: String
    @Binding var text: String
    let contentType: UITextContentType
    let isSecure: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(.secondary)
                .frame(width: 22)

            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
            }
            .textContentType(contentType)
            .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.white.opacity(0.12))
        }
    }
}