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
    @State private var inputText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Etichetta/Titolo
            Text("Write your text here:")
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(radius: 10)
                .padding(.horizontal, 32)
                .padding(.top)
            
            // Area di Input Testo
            ZStack(alignment: .topLeading) {
                // Background grigio chiaro per il riquadro con bordo
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 248/255, green: 249/255, blue: 252/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(minHeight: 300)
                
                TextEditor(text: $inputText)
                    .font(.body)
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
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 65/255, green: 72/255, blue: 112/255))
                    .cornerRadius(30)
                    .shadow(radius: 10)
                    .padding(.horizontal, 100)
                    .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
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
                            .foregroundColor(.black)
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
