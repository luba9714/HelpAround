//
//  View.swift
//  HelpAround
//
//  Created by Luba Gluhov on 12/07/2023.
//

import SwiftUI

extension View{
    func popupNavigationView<Content:View>(horizontalPadding: CGFloat = 40,show:Binding<Bool>,@ViewBuilder content:@escaping()->Content)-> some View{
        return self.overlay{
            if show.wrappedValue{
                GeometryReader{
                    proxy in
                    let size = proxy.size
                    
                    NavigationView{
                    
                        content()
                        
                    }
                    .frame(width: 270 , height: 350
                           , alignment: .center)
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 1)
                            .frame(width: 270 , height: 350
                                   , alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
     
                    )
            
                }
            }
        }
    }
}
