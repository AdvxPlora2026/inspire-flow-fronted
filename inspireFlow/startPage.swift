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
        ZStack {
            background

            VStack(spacing: 0) {
                header

                TabView(selection: $selectedPage) {
                    ForEach(pages) { page in
                        OnboardingCard(
                            page: page,
                            isSelected: selectedPage == page.id,
                            reduceMotion: reduceMotion
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
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

    private var background: some View {
        ZStack {
            Color(
                red: 0.025,
                green: 0.025,
                blue: 0.04
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    currentPage.accentColor.opacity(0.24),
                    currentPage.accentColor.opacity(0.07),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 520
            )
            .ignoresSafeArea()
            .animation(
                reduceMotion
                    ? nil
                    : .easeOut(duration: 0.28),
                value: selectedPage
            )

            RadialGradient(
                colors: [
                    Color.purple.opacity(0.13),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 450
            )
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack {
            Label("inspireFlow", systemImage: "sparkles")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Spacer()

            Text("\(selectedPage + 1) / \(pages.count)")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
    }

    private var footer: some View {
        VStack(spacing: 20) {
            pageIndicator

            Button {
                handlePrimaryAction()
            } label: {
                HStack(spacing: 10) {
                    Text(
                        selectedPage == pages.count - 1
                            ? "进入 inspireFlow"
                            : "继续"
                    )
                    .font(.headline)

                    Image(
                        systemName: selectedPage == pages.count - 1
                            ? "arrow.right"
                            : "chevron.right"
                    )
                    .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(
                    selectedPage == pages.count - 1
                        ? Color.black
                        : Color.white
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    Capsule()
                        .fill(
                            selectedPage == pages.count - 1
                                ? Color.white
                                : currentPage.accentColor
                        )
                }
            }
            .buttonStyle(OnboardingButtonStyle())
            .accessibilityHint(
                selectedPage == pages.count - 1
                    ? "完成引导并进入主界面"
                    : "前往下一页"
            )
        }
        .padding(.horizontal, 24)
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
                            ? currentPage.accentColor
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
                    .font(.caption.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(page.accentColor)

                Text(page.title)
                    .font(
                        .system(
                            size: 36,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.white)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(page.detail)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.62))
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
        .background(.ultraThinMaterial, in: cardShape)
        .overlay {
            cardShape
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            page.accentColor.opacity(0.18),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        }
        .shadow(
            color: page.accentColor.opacity(
                isSelected ? 0.16 : 0.06
            ),
            radius: isSelected ? 24 : 14,
            y: 14
        )
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
            Circle()
                .fill(page.accentColor.opacity(0.13))
                .frame(width: 154, height: 154)

            Circle()
                .strokeBorder(
                    page.accentColor.opacity(0.22),
                    lineWidth: 1
                )
                .frame(width: 122, height: 122)

            Image(systemName: page.symbol)
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            page.accentColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
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
                        .foregroundStyle(page.accentColor)

                    Text(feature)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
        }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: 32,
            style: .continuous
        )
    }
}

private struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(
                .easeOut(duration: 0.12),
                value: configuration.isPressed
            )
    }
}

private struct OnboardingPage: Identifiable {
    let id: Int
    let eyebrow: String
    let title: String
    let detail: String
    let symbol: String
    let accentColor: Color
    let features: [String]

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            eyebrow: "捕捉灵感",
            title: "想法出现时，立即留下它",
            detail: "双击戒指，说出刚刚出现的想法。PAWN 会保留现场语境，并在需要时继续追问。",
            symbol: "waveform",
            accentColor: .pink,
            features: [
                "戒指触发捕捉与确认",
                "耳机承载表达与私密反馈"
            ]
        ),
        OnboardingPage(
            id: 1,
            eyebrow: "继续创作",
            title: "从一句话，到完整作品",
            detail: "PAWN 会将内容加入对应项目，并逐步生成面向 Bilibili 的大纲、分镜和拍摄清单。",
            symbol: "wand.and.stars",
            accentColor: .purple,
            features: [
                "保持完整项目上下文",
                "整理视频结构与拍摄计划"
            ]
        ),
        OnboardingPage(
            id: 2,
            eyebrow: "准备发布",
            title: "让每个想法，继续向前",
            detail: "完善脚本和交付内容。商业项目还可以确认预算、授权与协作者分账。",
            symbol: "arrow.up.forward.circle.fill",
            accentColor: .blue,
            features: [
                "生成 Bilibili 发布材料",
                "清晰管理商业项目状态"
                            ]
        )
    ]
}

#Preview("PAWN Onboarding") {
    StartView(
        hasCompletedOnboarding: .constant(false)
    )
}
