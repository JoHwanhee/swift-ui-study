//
//  ContentView.swift
//  jetchat
//
//  Created by Hwanhee Jo on 2022/01/10.
//
//

import SwiftUI

class ImageLoaderService: ObservableObject {
    @Published var image: UIImage = UIImage()

    func loadImage(for urlString: String) {
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data) ?? UIImage()
            }
        }
        task.resume()
    }
}

struct CustomImageViewProperty {
    var urlString: String
    var width: CGFloat = 100
    var height: CGFloat = 100
}

struct CustomImageView: View {
    let props: CustomImageViewProperty

    @ObservedObject var imageLoader = ImageLoaderService()
    @State var image: UIImage = UIImage()

    var body: some View {
        // todo : 페치 전/중/후 상태를 나누고싶다..
        Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:props.width, height:props.height)
                .onReceive(imageLoader.$image) { image in
                    self.image = image
                }
                .onAppear {
                    imageLoader.loadImage(for: props.urlString)
                }
    }
}

struct MenuItem {
    var thumbnailUrl: String = ""
    let title: String
    let body: String
}

struct Row: View {
    let item: MenuItem

    var body: some View {
        HStack {
            if(!item.thumbnailUrl.isEmpty) {
                // todo : listStyle(.grouped) 이것 처럼 .default, .medium, .large 이렇게 만들고싶은데 어떻게 하는지 모르겠음..
                CustomImageView(
                        props: CustomImageViewProperty(
                                urlString: item.thumbnailUrl,
                                width: 100,
                                height: 100)
                )
            }
            VStack(alignment: .leading) {
                // todo : 텍스트의 테마는 어디서 관리하지?
                Text("\(item.title)")
                        .fontWeight(.bold)
                Text("\(item.body)")
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        // todo : 스타일이 none인건 없나..?
        // todo : 데이터를 리스트로 가지고 있게는 못 하는가?
        List {
            Row(item: MenuItem(thumbnailUrl: "https://upload3.inven.co.kr/upload/2021/04/12/bbs/i16288330962.jpg", title: "타이틀", body: "바디"))
            Row(item: MenuItem(title: "123", body: "123123"))
            Row(item: MenuItem(title: "123", body: "123123"))
        }.listStyle(.grouped)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
