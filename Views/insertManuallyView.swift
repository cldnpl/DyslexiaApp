//
//  insertManuallyView.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 14/01/26.
//

import SwiftUI

struct InsertManuallyView: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    @StateObject private var settings = AppSettings.shared
    @State private var inputText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Etichetta/Titolo
            Text("Write your text here:")
                .font(.app(size: settings.textSize * 2.125, weight: .bold, dyslexia: settings.dyslexiaFont))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top)
            
            // Area di Input Testo
            ZStack(alignment: .topLeading) {
                // Background grigio chiaro per il riquadro con bordo
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(uiColor: .separator), lineWidth: 1)
                    )
                    .frame(minHeight: 300)
                
                TextEditor(text: $inputText)
                    .font(.app(size: settings.textSize, weight: settings.boldText ? .bold : .regular, dyslexia: settings.dyslexiaFont))
                    .focused($isTextFieldFocused)
                    .frame(minHeight: 300)
                    .scrollContentBackground(.hidden)
                    .padding(10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Pulsante "Done"
            NavigationLink(destination: ReadingView(
                isPresented: $isPresented,
                selectedTab: $selectedTab,
                textToRead: inputText
            )) {
                Text("Done")
                    .font(.app(size: settings.textSize * 1.375, weight: .bold, dyslexia: settings.dyslexiaFont))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(settings.isDarkMode ? Color.primary : Color(.blue))
                    .cornerRadius(30)
                    .shadow(radius: 5)
                    .padding(.horizontal, 100)
                    .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 0 {
                    isTextFieldFocused = false
                }
                })

            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
            // Metti il focus sul text editor quando appare la vista
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    InsertManuallyView(isPresented: .constant(true), selectedTab: .constant(0))
}
