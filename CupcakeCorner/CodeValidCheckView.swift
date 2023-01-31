//
//  CodeValidCheckView.swift
//  CupcakeCorner
//
//  Created by joon-ho kil on 2023/01/27.
//

import SwiftUI

struct CodeValidCheckView: View {
    @State var code = ""
    @State var checkValidCompanyCode = false
    @State var isValidCompanyCode = false
    @State var checkValidInviteCode = false
    @State var isValidInviteCode = false
    
    var body: some View {
        TextField("코드", text: Binding<String>(
            get: { self.code },
            set: {
                self.code = $0
                self.checkValidCode($0)
            }
        ))
    }
    
    private func checkValidCode(_ code: String) {
        if code.count == 6 {
            checkValidCompanyCode(code)
        }
        if code.count == 8 {

        }
    }
    
    private func checkValidCompanyCode(_ code: String) {
        guard let url = URL(string: "http://api-stg-kr.paywatchglobal.com/join/v2.1/code/") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: String] = ["join_code": code]
                
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("-----> data: \(data)")
            print("-----> error: \(error)")
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }

            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            print("-----1> responseJSON: \(responseJSON)")
            if let responseJSON = responseJSON as? [String: Any] {
                checkValidCompanyCode = true
                print("-----2> responseJSON: \(responseJSON)")
                if let errorCode = responseJSON["error_code"] as? Int, errorCode == 400210 {
                    isValidCompanyCode = false
                    print("실패")
                } else {
                    isValidCompanyCode = true
                    print("성공")
                }
            }
        }
        
        task.resume()
    }
}

struct CodeValidCheckView_Previews: PreviewProvider {
    static var previews: some View {
        CodeValidCheckView()
    }
}
