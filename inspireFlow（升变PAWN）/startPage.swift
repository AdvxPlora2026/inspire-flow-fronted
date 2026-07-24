//
//  startPage.swift
//  inspireFlow
//
//  Created by 叶文峰 on 2026/7/23.
//

import SwiftUI

struct StartView: View {
    @Binding var hasCompletedOnboarding: Bool

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @State private var selectedPage = 0

    private let pages = OnboardingPage.pages

    var body: some View {
        ShengbianBackground {
            VStack(spacing: 0) {
                header

                TabView(selection: $selectedPage) {
                    ForEach(pages) { page in
                        OnboardingCard(
                            page: page,
                            isSelected: selectedPage == page.id,
                            reduceMotion: reduceMotion
                        )
                        .padding(.horizontal, ShengbianMetrics.pageMargin)
                        .padding(.vertical, 18)
                        .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .accessibilityLabel("功能引导")
                .accessibilityValue(
                    "第 \(selectedPage + 1) 页，共 \(pages.count) 页"
                )

                footer
            }
        }
        .preferredColorScheme(.dark)
    }

    private var currentPage: OnboardingPage {
        pages[selectedPage]
    }

    private var header: some View {
        HStack {
            AppBrandMark(compact: true)

            Spacer()

            Text("\(selectedPage + 1) / \(pages.count)")
                .font(ShengbianTypography.technical)
                .foregroundStyle(ShengbianColors.secondaryText)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, ShengbianMetrics.pageMargin)
        .padding(.top, 18)
    }

    private var footer: some View {
        VStack(spacing: 20) {
            pageIndicator

            ShengbianPrimaryButton(
                title: selectedPage == pages.count - 1 ? "进入升变" : "继续",
                symbol: selectedPage == pages.count - 1 ? "arrow.right" : "chevron.right",
                action: handlePrimaryAction
            )
            .accessibilityHint(
                selectedPage == pages.count - 1
                    ? "完成引导并进入主界面"
                    : "前往下一页"
            )
        }
        .padding(.horizontal, ShengbianMetrics.pageMargin)
        .padding(.bottom, 24)
        .animation(
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .easeOut(duration: 0.2),
            value: selectedPage
        )
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Capsule()
                    .fill(
                        selectedPage == page.id
                            ? Color.white
                            : Color.white.opacity(0.18)
                    )
                    .frame(
                        width: selectedPage == page.id ? 28 : 8,
                        height: 8
                    )
                    .animation(
                        reduceMotion
                            ? nil
                            : .easeOut(duration: 0.18),
                        value: selectedPage
                    )
                    .accessibilityHidden(true)
            }
        }
    }

    private func handlePrimaryAction() {
        if selectedPage == pages.count - 1 {
            completeOnboarding()
        } else {
            showNextPage()
        }
    }

    private func showNextPage() {
        guard selectedPage < pages.count - 1 else {
            return
        }

        if reduceMotion {
            selectedPage += 1
        } else {
            withAnimation(
                .spring(
                    response: 0.34,
                    dampingFraction: 0.88
                )
            ) {
                selectedPage += 1
            }
        }
    }

    private func completeOnboarding() {
        if reduceMotion {
            hasCompletedOnboarding = true
        } else {
            withAnimation(.easeOut(duration: 0.2)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

private struct OnboardingCard: View {
    let page: OnboardingPage
    let isSelected: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            Spacer(minLength: 0)

            illustration

            VStack(alignment: .leading, spacing: 14) {
                Text(page.eyebrow)
                    .font(ShengbianTypography.label)
                    .foregroundStyle(ShengbianColors.secondaryText)

                Text(page.title)
                    .font(ShengbianTypography.display)
                    .foregroundStyle(ShengbianColors.primaryText)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(page.detail)
                    .font(ShengbianTypography.title3)
                    .foregroundStyle(ShengbianColors.secondaryText)
                    .lineSpacing(6)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }

            featureList

            Spacer(minLength: 0)
        }
        .padding(26)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .background(.regularMaterial, in: cardShape)
        .background(ShengbianColors.glassTint, in: cardShape)
        .overlay {
            cardShape
            .strokeBorder(ShengbianColors.glassBorder, lineWidth: 0.8)
        }
        .scaleEffect(
            reduceMotion || isSelected
                ? 1
                : 0.98
        )
        .opacity(isSelected ? 1 : 0.86)
        .animation(
            reduceMotion
                ? .easeOut(duration: 0.15)
                : .easeOut(duration: 0.2),
            value: isSelected
        )
    }

    private var illustration: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                .fill(ShengbianColors.glassTintStrong)
                .frame(width: 132, height: 132)
                .overlay {
                    RoundedRectangle(cornerRadius: ShengbianMetrics.cardRadius, style: .continuous)
                        .strokeBorder(ShengbianColors.glassBorder)
                }

            Image(systemName: page.symbol)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(page.features, id: \.self) { feature in
                HStack(spacing: 11) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(ShengbianColors.primaryText)

                    Text(feature)
                        .font(ShengbianTypography.subheadline.weight(.medium))
                        .foregroundStyle(ShengbianColors.primaryText)
                }
            }
        }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: ShengbianMetrics.cardRadius,
            style: .continuous
        )
    }
}

private struct OnboardingPage: Identifiable {
    let id: Int
    let eyebrow: String
    let title: String
    let detail: String
    let symbol: String
    let features: [String]

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            eyebrow: "第一步：接住灵感",
            title: "想到就说，轻点即录",
            detail: "灵感出现的那一刻，轻点屏幕就能开始录音。PAWN 全程本地运行，不需要网络，不打断当下的状态。",
            symbol: "waveform",
            features: [
                "轻点即录，随时可用",
                "可选：Zilo 戒指无屏触发"
            ]
        ),
        OnboardingPage(
            id: 1,
            eyebrow: "第二步：PAWN 三问",
            title: "三个问题，打开一个方向",
            detail: "录音结束后，PAWN 会连续问三个问题：目标观众、内容形式、关键开场画面——帮你把一句话变成可执行的创作方向。",
            symbol: "sparkles",
            features: [
                "语音回答，无需打字",
                "追问让想法更具体"
            ]
        ),
        OnboardingPage(
            id: 2,
            eyebrow: "第三步：拿到成品包",
            title: "标题、钩子、大纲、分镜",
            detail: "三问结束，PAWN 生成一份完整的 Bilibili 创作方案：标题、3 秒钩子、章节大纲和可拍摄分镜。商业项目还自动进入结算流程。",
            symbol: "arrow.up.forward.circle.fill",
            features: [
                "生成 Bilibili 发布材料",
                "商业项目链上结算凭证"
            ]
        )
    ]
}

#Preview("PAWN Onboarding") {
    StartView(
        hasCompletedOnboarding: .constant(false)
    )
}
