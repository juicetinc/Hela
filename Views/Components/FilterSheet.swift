import SwiftUI

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedCategory: String
    @Binding var selectedCollection: String
    @Binding var sortBy: String
    
    let categories = ["All", "Bag", "Recipe", "Receipt", "Fashion", "Decor", "Document", "Note"]
    let collections: [String]
    let sorts = ["Newest", "A–Z", "Most Qty", "Color"]
    
    init(
        selectedCategory: Binding<String>,
        selectedCollection: Binding<String>,
        sortBy: Binding<String>,
        collections: [String] = ["All"]
    ) {
        self._selectedCategory = selectedCategory
        self._selectedCollection = selectedCollection
        self._sortBy = sortBy
        self.collections = collections
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                } header: {
                    Text("Category")
                }
                
                if collections.count > 1 {
                    Section {
                        Picker("Collection", selection: $selectedCollection) {
                            ForEach(collections, id: \.self) { collection in
                                Text(collection).tag(collection)
                            }
                        }
                    } header: {
                        Text("Collection")
                    }
                }
                
                Section {
                    Picker("Sort by", selection: $sortBy) {
                        ForEach(sorts, id: \.self) { sort in
                            Text(sort).tag(sort)
                        }
                    }
                } header: {
                    Text("Sort")
                }
                
                Section {
                    Button("Reset Filters") {
                        selectedCategory = "All"
                        selectedCollection = "All"
                        sortBy = "Newest"
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var category = "All"
        @State private var collection = "All"
        @State private var sort = "Newest"
        
        var body: some View {
            FilterSheet(
                selectedCategory: $category,
                selectedCollection: $collection,
                sortBy: $sort,
                collections: ["All", "Gift Bags", "Closet", "Kitchen"]
            )
        }
    }
    
    return PreviewWrapper()
}

