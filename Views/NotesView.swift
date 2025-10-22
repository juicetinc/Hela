import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntry.createdAt, ascending: false)],
        animation: .default)
    private var notes: FetchedResults<NoteEntry>
    
    @State private var showingAddNote = false
    @State private var showingImportNote = false
    @State private var searchText = ""
    
    var filteredNotes: [NoteEntry] {
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
            VStack {
                // Debug indicator
                Text("NotesView Active - Notes: \(notes.count)")
                    .font(.caption)
                    .padding(8)
                    .background(Color.blue.opacity(0.3))
                
                Group {
                        if filteredNotes.isEmpty {
                        // Simple empty state that works on all iOS versions
                        VStack(spacing: 16) {
                            Image(systemName: searchText.isEmpty ? "note.text" : "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundStyle(.secondary)
                            
                            Text(searchText.isEmpty ? "No Notes" : "No Results")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(searchText.isEmpty ? "Tap + to add a note" : "Try a different search")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        List {
                            ForEach(filteredNotes, id: \.objectID) { note in
                                NavigationLink {
                                    NoteDetailView(note: note)
                                } label: {
                                    NoteRow(note: note)
                                }
                            }
                            .onDelete(perform: deleteNotes)
                        }
                    }
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingImportNote = true
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
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

struct NoteRow: View {
    @ObservedObject var note: NoteEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let title = note.title {
                    Text(title)
                        .font(.headline)
                }
                
                Spacer()
                
                if let category = note.category {
                    Text(category.uppercased())
                        .font(.system(size: 10))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.purple)
                        )
                }
            }
            
            if let body = note.body, !body.isEmpty {
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            if let createdAt = note.createdAt {
                Text(createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var note: NoteEntry
    @State private var isEditing = false
    
    // Editable fields
    @State private var editTitle: String = ""
    @State private var editBody: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                if isEditing {
                    TextField("Title", text: $editTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .textFieldStyle(.roundedBorder)
                } else {
                    if let title = note.title {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                
                if let category = note.category {
                    Text(category.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.purple)
                        )
                }
                
                // Body
                if isEditing {
                    TextEditor(text: $editBody)
                        .font(.body)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    if let body = note.body {
                        Text(body)
                            .font(.body)
                    }
                }
                
                if let tagsCSV = note.tagsCSV, !tagsCSV.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tagsCSV.split(separator: ",").map(String.init), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.purple.opacity(0.1))
                                        )
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Note Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if isEditing {
                        saveChanges()
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                }
            }
        }
        .onAppear {
            loadEditState()
        }
    }
    
    private func loadEditState() {
        editTitle = note.title ?? ""
        editBody = note.body ?? ""
    }
    
    private func saveChanges() {
        note.title = editTitle
        note.body = editBody
        
        do {
            try viewContext.save()
            print("Note saved successfully")
        } catch {
            print("Error saving note: \(error)")
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title = ""
    @State private var noteBody = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Note title", text: $title)
                }
                
                Section("Content") {
                    TextEditor(text: $noteBody)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty && noteBody.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let noteTitle = title.isEmpty ? "Untitled" : title
        
        InventoryStore.shared.saveNote(
            title: noteTitle,
            body: noteBody,
            category: "note",
            tags: ["note"],
            attributes: [:],
            context: viewContext
        )
        
        dismiss()
    }
}

struct ImportNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var pastedText = ""
    @State private var isProcessing = false
    @State private var showingFilePicker = false
    @State private var importedNoteData: NoteData?
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Paste your note content below, or import from a file.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $pastedText)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                } header: {
                    Text("Note Content")
                }
                
                Section {
                    Button {
                        showingFilePicker = true
                    } label: {
                        Label("Import from File (.txt, .html)", systemImage: "doc")
                    }
                } header: {
                    Text("Or Import File")
                }
                
                if let noteData = importedNoteData {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            LabeledContent("Title", value: noteData.title)
                            LabeledContent("Category", value: noteData.category.capitalized)
                            LabeledContent("Tags", value: noteData.tags.joined(separator: ", "))
                        }
                        .font(.subheadline)
                    } header: {
                        Text("Preview")
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Import Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Import") {
                        Task {
                            await importNote()
                        }
                    }
                    .disabled(pastedText.isEmpty || isProcessing)
                }
            }
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Processing...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.plainText, .html],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
        }
    }
    
    private func importNote() async {
        isProcessing = true
        errorMessage = nil
        
        do {
            // Process the note
            let noteData = await NoteImporter.shared.importNote(text: pastedText)
            
            await MainActor.run {
                importedNoteData = noteData
                
                // Save to Core Data
                InventoryStore.shared.saveNote(
                    title: noteData.title,
                    body: noteData.body,
                    category: noteData.category,
                    tags: noteData.tags,
                    attributes: [:],
                    context: viewContext
                )
                
                isProcessing = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to import note: \(error.localizedDescription)"
                isProcessing = false
            }
        }
    }
    
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let text = try String(contentsOf: url, encoding: .utf8)
                pastedText = text
                
                Task {
                    await importNote()
                }
            } catch {
                errorMessage = "Failed to read file: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            errorMessage = "Failed to import file: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NotesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

