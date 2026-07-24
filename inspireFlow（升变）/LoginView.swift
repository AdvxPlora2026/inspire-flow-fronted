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
        ShengbianBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    brandHeader
                    rolePicker
                    ShengbianGlassCard(emphasis: .prominent) {
                        VStack(spacing: 16) {
                            credentialsForm
                            primaryButton
                        }
                    }
                    modeButton
                }
                .padding(.horizontal, ShengbianMetrics.pageMargin)
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppBrandMark()
                .padding(.bottom, 12)

            Text(isCreatingAccount ? "创建你的工作空间" : "欢迎回来")
                .font(ShengbianTypography.display)
                .contentTransition(.opacity)

            Text(isCreatingAccount ? "选择身份，让 PAWN 从你的第一条灵感开始。" : "回到你的灵感、项目和创作上下文。")
                .shengbianBodyText(secondary: true)
        }
    }

    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("你的身份")
                .font(ShengbianTypography.headline)

            HStack(spacing: 10) {
                ForEach(UserRole.allCases) { role in
                    Button {
                        Haptics.selection()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                            selectedRole = role
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: role.symbol)
                                .font(.title3.weight(.semibold))
                                .symbolEffect(.bounce, value: selectedRole == role)

                            Text(role.title)
                                .font(ShengbianTypography.headline)

                            Text(role.detail)
                                .font(ShengbianTypography.caption)
                                .foregroundStyle(selectedRole == role ? ShengbianColors.inverseText.opacity(0.62) : ShengbianColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .foregroundStyle(selectedRole == role ? ShengbianColors.inverseText : ShengbianColors.primaryText)
                        .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
                        .padding(14)
                        .background(
                            selectedRole == role ? ShengbianColors.primaryAction : ShengbianColors.glassTint,
                            in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                        )
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                                .strokeBorder(selectedRole == role ? Color.clear : ShengbianColors.glassBorder)
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
        ShengbianPrimaryButton(
            title: isCreatingAccount ? "创建并进入" : "登录",
            symbol: "arrow.right",
            action: submit
        )
    }

    private var modeButton: some View {
        Button {
            isCreatingAccount.toggle()
            hasAttemptedSubmit = false
        } label: {
            Text(isCreatingAccount ? "已有账号？登录" : "还没有账号？创建账号")
                .font(ShengbianTypography.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
            .foregroundStyle(ShengbianColors.primaryText)
    }

    private var isValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    private func submit() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            hasAttemptedSubmit = true
        }
        guard isValid else {
            Haptics.error()
            return
        }
        focusedField = nil
        if isCreatingAccount {
            session.register(email: email, role: selectedRole)
        } else {
            session.signIn(email: email, role: selectedRole)
        }
        Haptics.success()
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
        .background(ShengbianColors.glassTint, in: RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: ShengbianMetrics.controlRadius, style: .continuous)
                .strokeBorder(ShengbianColors.glassBorder)
        }
    }
}