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
            
            // Label/Title
            Text("Write your text here:")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(settings.customFont(size: settings.textSize * 2.125, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top)
            
            // Text input area
            ZStack(alignment: .topLeading) {
                // Light gray background for bordered box
                RoundedRectangle(cornerRadius: 12)
                    .fill(settings.textFieldBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(uiColor: .separator), lineWidth: 1)
                    )
                    .frame(minHeight: 300)
                
                TextEditor(text: $inputText)
                    .font(settings.customFont(size: settings.textSize, weight: settings.boldText ? .bold : .regular))
                    .foregroundColor(settings.textColor)
                    .focused($isTextFieldFocused)
                    .frame(minHeight: 300)
                    .scrollContentBackground(.hidden)
                    .padding(10)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // "Done" button
            NavigationLink(destination: ReadingView(
                isPresented: $isPresented,
                selectedTab: $selectedTab,
                textToRead: inputText
            )) {
                Text("Done")
                    .font(settings.customFont(size: settings.textSize * 1.375, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(settings.accentColor)
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
            // Focus text editor when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    InsertManuallyView(isPresented: .constant(true), selectedTab: .constant(0))
}
