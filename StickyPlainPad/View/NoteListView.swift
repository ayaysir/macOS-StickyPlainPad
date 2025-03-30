//
//  NoteListView.swift
//  StickyPlainPad
//
//  Created by 윤범태 on 3/29/25.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
  @Environment(\.openWindow) private var openWindow
  
  @State private var viewModel: NoteViewModel
  
  init(context: ModelContext) {
    _viewModel = State(
      initialValue: NoteViewModel(
        repository: NoteRepositoryImpl(context: context)
      )
    )
  }
  
  init(viewModel: NoteViewModel) {
    _viewModel = State(initialValue: viewModel)
  }
  
  var body: some View {
    VStack {
      List {
        Button(action: addItem) {
          Label("Add", systemImage: "plus")
        }
        
        ForEach(viewModel.notes) { note in
          Button {
            // openWindow(value: note.id)
            openCustomWindow(value: note.id)
          } label: {
            Text("\(note.content), \(note.createdAt)")
          }
          .contextMenu {
            Button(role: .destructive) {
              viewModel.deleteNote(note)
            } label: {
              Text("삭제")
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
    }
    .onAppear {
      // viewModel.notes.forEach {
      //   openWindow(value: $0.id)
      // }
    }
  }
  
  private func addItem() {
    withAnimation {
      viewModel.addEmptyNote()
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        viewModel.deleteNote(index: index)
      }
    }
  }
  
  func generateRandomUppercaseString(length: Int = 5) -> String {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    return String((0..<length).map { _ in letters.randomElement()! })
  }
}

extension NoteListView {
  // openWindow 대신 CustomWindow를 띄우는 방법
  func openCustomWindow(value: UUID) {
    if NSApplication.shared.windows.contains(where: { $0.title == value.uuidString }) {
      return
    }
    
    // 화면의 중앙에 창 위치 계산
    let screenSize = NSScreen.main?.frame ?? .zero
    let windowSize = CGSize(width: 400, height: 300)
    let windowFrame = CGRect(
      x: (screenSize.width - windowSize.width) / 2,
      y: (screenSize.height - windowSize.height) / 2,
      width: windowSize.width,
      height: windowSize.height
    )

    // CustomWindow 생성
    let customWindow = NoteEditWindow(
      contentRect: windowFrame,
      styleMask: [.borderless, .fullSizeContentView, .resizable],
      backing: .buffered,
      defer: false
    )

    // CustomWindow 스타일 설정
    customWindow.titlebarAppearsTransparent = true
    customWindow.isMovableByWindowBackground = true
    
    // NoteEditView를 NSHostingView로 감싸서 CustomWindow의 콘텐츠로 설정
    let noteEditView = NoteEditView(
      noteViewModel: viewModel,
      noteID: value
    )
    let hostingView = NSHostingView(rootView: noteEditView)
    hostingView.frame = customWindow.contentView?.bounds ?? .zero
    customWindow.contentView?.addSubview(hostingView)
    customWindow.title = "\(value)"
    
    // EXC_BAD_ACCESS 오류 https://stackoverflow.com/a/75341381
    customWindow.isReleasedWhenClosed = false

    // 창을 활성화하고 보이게 하기
    customWindow.makeKeyAndOrderFront(nil)
  }
  
}

#Preview {
  NoteListView(
    context: .forPreviewContext
  )
}
