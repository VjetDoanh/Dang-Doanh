import SwiftUI

private let lime = Color(red: 0.53, green: 0.92, blue: 0.24)
private let panel = Color(red: 0.075, green: 0.085, blue: 0.095)
private let panel2 = Color(red: 0.11, green: 0.12, blue: 0.13)

enum AimTarget: String, CaseIterable, Identifiable {
    case head = "HEAD"
    case drag = "DRAG"
    case neck = "NECK"
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var menuVisible = true
    @State private var esp = true
    @State private var silentAim = false
    @State private var aimSystem = true
    @State private var fovCircle = true
    @State private var noRecoil = false
    @State private var fov: Double = 120
    @State private var target: AimTarget = .head
    @State private var bubblePosition = CGPoint(x: 70, y: 130)

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()

                // Demo background only: this app is an independent UI prototype.
                LinearGradient(
                    colors: [Color.black, Color(red: 0.03, green: 0.06, blue: 0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if menuVisible {
                    menu
                        .frame(maxWidth: 360)
                        .padding(.horizontal, 18)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    floatingBubble(in: proxy.size)
                }
            }
            .animation(.spring(response: 0.28), value: menuVisible)
        }
    }

    private var menu: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MENU")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                    Text("INDEPENDENT UI")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer()

                Circle()
                    .fill(lime)
                    .frame(width: 9, height: 9)
                    .shadow(color: lime.opacity(0.65), radius: 7)

                Button {
                    menuVisible = false
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 30)
                        .background(panel2)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(panel2)

            ScrollView {
                VStack(spacing: 10) {
                    ToggleRow(title: "Enable ESP", subtitle: "Display overlay preview", isOn: $esp)
                    ToggleRow(title: "Silent aim", subtitle: "UI option only", isOn: $silentAim)
                    ToggleRow(title: "Aim system", subtitle: "UI option only", isOn: $aimSystem)

                    SectionCard {
                        HStack {
                            Text("Aim FOV circle")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Toggle("", isOn: $fovCircle)
                                .labelsHidden()
                                .tint(lime)
                        }

                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Text("FOV radius")
                                    .foregroundStyle(.white.opacity(0.72))
                                Spacer()
                                Text("\(Int(fov))")
                                    .foregroundStyle(lime)
                                    .fontWeight(.bold)
                            }
                            Slider(value: $fov, in: 30...300, step: 1)
                                .tint(lime)
                        }

                        Divider().overlay(.white.opacity(0.08))

                        HStack {
                            Text("Aim system target")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Picker("", selection: $target) {
                                ForEach(AimTarget.allCases) { item in
                                    Text(item.rawValue).tag(item)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(lime)
                        }
                    }

                    ToggleRow(title: "No recoil", subtitle: "UI option only", isOn: $noRecoil)

                    Button {
                        menuVisible = false
                    } label: {
                        HStack {
                            Image(systemName: "eye.slash")
                            Text("HIDE MENU")
                                .fontWeight(.heavy)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .padding(15)
                        .background(lime.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lime.opacity(0.55), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
            }
            .frame(maxHeight: 560)
        }
        .foregroundStyle(.white)
        .background(panel)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(lime.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.55), radius: 24, y: 12)
    }

    private func floatingBubble(in size: CGSize) -> some View {
        Circle()
            .fill(lime)
            .frame(width: 58, height: 58)
            .overlay(
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
            )
            .shadow(color: lime.opacity(0.45), radius: 12)
            .position(bubblePosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        bubblePosition = value.location
                    }
            )
            .onTapGesture {
                menuVisible = true
            }
    }
}

private struct SectionCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 13) {
            content
        }
        .padding(14)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(isOn ? lime.opacity(0.2) : Color.white.opacity(0.06))
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: isOn ? "checkmark" : "circle")
                        .foregroundStyle(isOn ? lime : .white.opacity(0.45))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(lime)
        }
        .padding(13)
        .background(panel2)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }
}
