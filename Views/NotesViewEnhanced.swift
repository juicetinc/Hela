import SwiftUI
import CoreData

struct NotesViewEnhanced: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntry.createdAt, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<NoteEntry>
    
    @State private var searchText = ""
    @State private var showingAddNote = false
    @State private var showingImportNote = false
    
    private var filteredNotes: [NoteEntry] {
        if searchText.isEmpty {
            return Array(notes)
        }
        
        return notes.filter { note in
            let searchLower = searchText.lowercased()
            return note.title?.lowercased().contains(searchLower) == true ||
                   note.body?.lowercased().contains(searchLower) == true ||
                   note.tagsCSV?.lowercased().contains(searchLower) == true
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredNotes.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredNotes, id: \.objectID) { note in
                            NavigationLink {
                                NoteDetailViewEnhanced(note: note)
                            } label: {
                                NoteRowComponent(
                                    title: note.title ?? "Untitled",
                                    preview: note.body ?? "",
                                    date: note.createdAt ?? Date(),
                                    tags: (note.tagsCSV ?? "").split(separator: ",").map(String.init)
                                )
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingImportNote = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
            }
            .sheet(isPresented: $showingImportNote) {
                ImportNoteView()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: HelaTheme.spacingL) {
            Image(systemName: searchText.isEmpty ? "note.text" : "magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text(searchText.isEmpty ? "No Notes" : "No Results")
                .font(HelaTheme.Typography.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? "Tap + to add a note" : "Try a different search")
                .font(HelaTheme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(HelaTheme.spacingXL)
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredNotes[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting notes: \(error)")
            }
        }
    }
}

struct NoteDetailViewEnhanced: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var note: NoteEntry
    
    @State private var showEdit = false
    
    private var tags: [String] {
        (note.tagsCSV ?? "").split(separator: ",").map(String.init)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: HelaTheme.spacingL) {
                // Title
                Text(note.title ?? "Untitled")
                    .font(HelaTheme.Typography.title)
                    .bold()
                
                // Category badge
                if let category = note.category, !category.isEmpty {
                    Text(category.uppercased())
                        .font(HelaTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, HelaTheme.spacingM)
                        .padding(.vertical, HelaTheme.spacingS)
                        .background(
                            Capsule()
                                .fill(HelaTheme.Colors.noteAccent)
                        )
                }
                
                // Body
                if let body = note.body, !body.isEmpty {
                    Text(body)
                        .font(HelaTheme.Typography.body)
                }
                
                // Tags
                if !tags.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: HelaTheme.spacingS) {
                        Text("Tags")
                            .font(HelaTheme.Typography.headline)
                        
                        FlowLayoutSimple(spacing: 6) {
                            ForEach(tags, id: \.self) { tag in
                                TagChip(text: tag)
                            }
                        }
                    }
                }
                
                // Metadata
                Divider()
                
                if let createdAt = note.createdAt {
                    HStack {
                        Text("Created")
                            .font(HelaTheme.Typography.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(HelaTheme.Typography.subheadline)
                    }
                }
            }
            .padding(HelaTheme.spacingL)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEdit = true
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            NoteDetailView(note: note)
        }
    }
}

#Preview {
    NotesViewEnhanced()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

