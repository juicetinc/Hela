import SwiftUI
import PhotosUI
import CoreData

struct CaptureView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var viewModel = CaptureViewModel()
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            VStack {
                // Debug indicator
                Text("📷 CaptureView Active")
                    .font(.caption)
                    .padding(4)
                    .background(Color.blue.opacity(0.3))
                
                ScrollView {
                    VStack(spacing: 30) {
                    // Image display area
                    if let cgImage = viewModel.selectedImage {
                        Image(decorative: cgImage, scale: 1.0)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 350, maxHeight: 350)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        // Placeholder when no image selected - tappable to open photo picker
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(width: 350, height: 350)
                                .overlay(
                                    VStack(spacing: 16) {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.system(size: 70))
                                            .foregroundStyle(.secondary)
                                        Text("Select a photo to analyze")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                    }
                                )
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Analyzing indicator
                    if viewModel.isAnalyzing {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Analyzing…")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Saving indicator
                    if viewModel.isSaving {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Saving…")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                // Show classification result if available
                if let itemRecord = viewModel.itemRecord, !viewModel.isAnalyzing {
                    VStack(spacing: 12) {
                        Text(itemRecord.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text(itemRecord.category.uppercased())
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                        
                        Text(itemRecord.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(itemRecord.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(.systemGray5))
                                        )
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 16)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Show error if classification failed
                if let error = viewModel.classificationError, !viewModel.isAnalyzing {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 16)
                    .transition(.scale.combined(with: .opacity))
                }
                    
                    // Debug JSON output
                    if !viewModel.debugJSON.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vision Analysis (Debug)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                Text(viewModel.debugJSON)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.primary)
                                    .padding(12)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                            .frame(maxHeight: 200)
                        }
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    }
                    .padding()
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Primary action button - fixed at bottom
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title3)
                        Text("Take or Choose Photo")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.gradient)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .buttonStyle(.plain)
            }
            .navigationTitle("Capture")
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedImage)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isAnalyzing)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isSaving)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.itemRecord?.title)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.debugJSON)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.classificationError)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showSavedIndicator)
            .overlay(alignment: .top) {
                // "Saved" indicator
                if viewModel.showSavedIndicator {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Saved")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThickMaterial)
                            .shadow(radius: 4)
                    )
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    await viewModel.loadImage(from: newValue)
                }
            }
            .sheet(isPresented: $viewModel.showConfirmation) {
                ConfirmationSheet(viewModel: viewModel, context: viewContext)
            }
        }
    }
}

struct ConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CaptureViewModel
    let context: NSManagedObjectContext
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Title", text: $viewModel.editableTitle)
                    
                    TextField("Summary", text: $viewModel.editableSummary, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Category", selection: $viewModel.editableCategory) {
                        ForEach(ItemRecord.validCategories, id: \.self) { category in
                            Text(category.capitalized).tag(category)
                        }
                    }
                }
                
                Section("Tags") {
                    TextField("Tags (comma-separated)", text: $viewModel.editableTags)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Organization") {
                    TextField("Collection (optional)", text: $viewModel.editableCollection)
                    
                    Stepper("Quantity: \(viewModel.editableQuantity)", value: $viewModel.editableQuantity, in: 1...999)
                }
            }
            .navigationTitle("Confirm & Save")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveItem(viewContext: context)
                            dismiss()
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    CaptureView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
