//
// CUIExpandableButton
//
// MIT License
//
// Copyright (c) 2022 Robert Cole
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import SwiftUI

/// View that can be used as a placeholder for previews.
///
/// Placeholder views are especially useful when displaying previews for layouts or views that host content. This view also provides several pieces of information:
/// 1. index - When no override is provided, an index will be assigned. Each new view will  increment the index upon the view's appearence and decremented on a view's disappearence. I.e. the first view displayed will have an index of 0 and the last view displayed will have an index of `n`. Provided indexes do not increment the index of the views.
/// 2. size - The size of the view is useful for view's that are expected to correctly calculate the view.
/// 3. position - This is the position in the global coordinate space. Useful when debugging layout issue.
public struct CUIPlaceholderView: View {
    static var index = 0

    @State
    var index: Int = 0

    var color: Color {
        colorOverride ?? Color.random(deterministicIndex: index)
    }

    let indexOverrode: Bool
    let cornerRadius: CGFloat?
    let colorOverride: Color?
    let showIndex: Bool
    let showSize: Bool
    let showPosition: Bool


    /// Creates a placeholder view.
    /// - Parameters:
    ///   - indexOverride: Overrides the index used to determine the view's color.
    ///         When provided an asterisk \* will be placed next to the view's index.
    ///   - colorOverride: Overrides the color of the view.
    ///   - cornerRadius: The radius for the corners of the view.
    ///   - showIndex: When false, the index will not be displayed
    ///   - showSize: When false, the size will not be displayed.
    ///   - showPosition: When false, the position will not be displayed.
    public init(
        indexOverride: Int? = nil,
        colorOverride: Color? = nil,
        cornerRadius: CGFloat = 0,
        showIndex: Bool = true,
        showSize: Bool = true,
        showPosition: Bool = true
    ) {
        self.index = indexOverride ?? 0
        self.indexOverrode = indexOverride != nil
        self.colorOverride = colorOverride
        self.cornerRadius = cornerRadius
        self.showIndex = showIndex
        self.showSize = showSize
        self.showPosition = showPosition
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius ?? 0)
                    .foregroundColor(color)

                VStack {
                    if showIndex {
                        Text("\(index)\(indexOverrode ? "*" : "")")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    if showSize {
                        Text(
                            String(format: "%.0f x %.0f", geometry.size.width, geometry.size.height)
                        )
                        .font(.caption)
                        .foregroundColor(.white)
                    }

                    if showPosition {
                        Text(
                            String(format: "(%.0f, %.0f)", geometry.frame(in: .global).minX, geometry.frame(in: .global).minY)
                        )

                        .font(.caption)
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            guard !indexOverrode else {
                return
            }

            index = CUIPlaceholderView.index
            CUIPlaceholderView.index += 1
        }
        .onDisappear {
            guard !indexOverrode else {
                return
            }

            CUIPlaceholderView.index -= 1
        }
    }
}

extension Color {
    static func random(deterministicIndex: Int? = nil) -> Color {
        let colors: [Color] = [.gray, .yellow, .teal, .green, .pink, .blue, .brown, .purple, .indigo, .mint, .red]

        guard let deterministicIndex else {
            return colors[.random(in: 0 ..< colors.count)]
        }

        return colors[deterministicIndex % colors.count]
    }
}

struct CUIPlaceholderView_Previews: PreviewProvider {
    static let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    static var previews: some View {
        VStack {
            Text("No index provided")
            HStack {
                CUIPlaceholderView(colorOverride: .black)
                CUIPlaceholderView(cornerRadius: 10)
                CUIPlaceholderView(showIndex: false)
                CUIPlaceholderView(showSize: false)
                CUIPlaceholderView(showPosition: false)
            }
            .frame(height: 100)

            Text("Provided Index")
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(0 ..< 100, id: \.self) { index in
                        CUIPlaceholderView(indexOverride: index)
                            .frame(minWidth: 100, minHeight: 50)
                    }
                }
            }
        }
    }
}
