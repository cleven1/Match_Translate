//
//  ContentView.swift
//  MatchComments
//
//  Created by zhaoyongqiang on 2024/1/16.
//

import SwiftUI

struct ContentView: View {
    @State private var filePath: String = ""
    @State private var filterFilePath: String = ""
    @State private var filterText: String = ""
    @State private var isShowFilePicker: Bool = false
    @State private var notes: String = "待翻译"
    @State private var startTitle: String = "开始翻译"
    @State private var isStart: Bool = false
    @State private var fromSelectedOption = "中文"
    @State private var toSelectedOption = "英文"
    let options = ["自动": "auto", "中文": "zh", "英文": "en"]
    
    var body: some View {
        VStack {
            HStack {
                Text("文件路径:")
                TextField("请输入文件路径, 递归遍历当前路径下的子路径", text: $filePath).textFieldStyle(.roundedBorder).padding()
                Button(action: {
                    isShowFilePicker = true
                }, label: {
                    Text("选择文件")
                }).fileImporter(
                    isPresented: $isShowFilePicker,
                    allowedContentTypes: [.directory],
                    onCompletion: { result in
                        do {
                            filePath = try result.get().path().trimmingCharacters(in: .whitespacesAndNewlines)
                            // 处理文件
                        } catch {
                            // 处理错误
                        }
                    }
                )
            }
            HStack {
                Text("过滤文件夹:")
                TextField("请输入要过滤的文件夹名称, 多个用逗号分割", text: $filterFilePath).textFieldStyle(.roundedBorder).padding()
            }
            HStack {
                Text("过滤文本")
                TextField("请输入要过滤的文本, 多个用逗号分割, 默认会过滤国际化的文本", text: $filterText).textFieldStyle(.roundedBorder).padding()
            }
            HStack {
                Text("目前只支持中文翻译英文").foregroundStyle(.pink)
                Spacer()
            }
            HStack {
                fromTranslatePicker().frame(maxWidth: 200)
                toTranslatePicker().frame(maxWidth: 200)
                Spacer()
            }.padding(.bottom)
            
            Button(action: {
                isStart = !isStart
                matchChinese()
            }, label: {
                Text(startTitle)
            }).disabled(filePath.isEmpty)
            Spacer()
            HStack {
                ScrollView(.vertical) {
                    Text(notes)
                }
                Spacer()
            }
        }
        .padding()
    }
    
    private func fromTranslatePicker() -> some View {
        VStack {
            Picker("From Language", selection: $fromSelectedOption) {
                ForEach(options.sorted(by: <), id: \.key) { key, value in
                                Text("\(key): \(value)")
                            }
            }.disabled(true)
        }
    }
    private func toTranslatePicker() -> some View {
        VStack {
            Picker("To Language", selection: $toSelectedOption) {
                ForEach(options.sorted(by: <), id: \.key) { key, value in
                                Text("\(key): \(value)")
                            }
            }.disabled(true)
        }
    }
    
    private func matchChinese() {
        if isStart {
            notes = "翻译中..."
            startTitle = "停止翻译"
            if filePath.contains(where: { $0.isWhitespace }) {
                notes = "文件路径中存在空格,请修改"
                return
            }
            guard let scriptPath = Bundle.main.path(forResource: "match_chinese_comments", ofType: "py") else { return }
            let from = options[fromSelectedOption] ?? "auto"
            let to = options[toSelectedOption] ?? "auto"
            Task {
                guard let result = try? await Util.runCommand(scriptPath,
                                                              filePath: filePath,
                                                              filterFile: filterFilePath,
                                                              filterText: filterText,
                                                              from: from, to: to) else { return }
                self.notes = result.executeResult ?? ""
                if !result.isSuccess {
                    self.notes = "翻译失败: \(result.executeResult ?? "")"
                }
                startTitle = "开始翻译"
            }
        } else {
            notes = "待翻译..."
            startTitle = "开始翻译"
            Util.stop()
        }
    }
}


#Preview {
    ContentView()
}
