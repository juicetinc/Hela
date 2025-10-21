import SwiftUI

/// A layout that arranges its children in a flowing manner, wrapping to new lines as needed
struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content
    
    @State private var totalHeight: CGFloat = 0
    
    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lastHeight: CGFloat = 0
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(Mirror(reflecting: content()).children.enumerated()), id: \.offset) { index, child in
                if let view = child.value as? any View {
                    AnyView(view)
                        .padding(.trailing, spacing)
                        .padding(.bottom, spacing)
                        .alignmentGuide(.leading) { dimension in
                            if abs(width - dimension.width) > geometry.size.width {
                                width = 0
                                height -= lastHeight
                            }
                            lastHeight = dimension.height
                            let result = width
                            if index == Mirror(reflecting: content()).children.count - 1 {
                                width = 0
                            } else {
                                width -= dimension.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { dimension in
                            let result = height
                            if index == Mirror(reflecting: content()).children.count - 1 {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    totalHeight = geo.size.height
                }
            }
        )
    }
}

// Simpler implementation using ViewBuilder
struct FlowLayoutSimple: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Flow Layout Preview").font(.headline)
        
        FlowLayoutSimple(spacing: 6) {
            ForEach(["leather", "vintage", "designer", "handbag", "blue", "imported", "luxury"], id: \.self) { tag in
                TagChip(text: tag)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    .padding()
}

