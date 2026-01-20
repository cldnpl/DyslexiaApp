//
//  ActionButton.swift
//  DyslexiaReader
//
//  Created by Claudia Napolitano on 14/01/26.
//

import SwiftUI

struct ActionButton: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 22.5){
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 60)
                
                Text(title)
                    .font(.largeTitle.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
            }
            .foregroundColor(.black)
            .padding(.vertical, 40)
            .padding(.leading, 20)
        }
        .frame(width: 350, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 182/255, green: 212/255, blue: 177/255))
                
        )
        .padding(.horizontal)
        .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}
#Preview {
    VStack(spacing: 20) {
        ActionButton(iconName: "camera", title: "Scan your text", action: {})
        ActionButton(iconName: "pencil.and.scribble", title: "Insert manually", action: {})
    }
}

