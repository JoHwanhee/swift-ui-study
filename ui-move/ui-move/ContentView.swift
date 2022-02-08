//
//  ContentView.swift
//  ui-move
//
//  Created by 조환희 on 2022/01/23.
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
    var id: Int
    var thumbnailUrl: String = ""
    let title: String
    let body: String
    let description: String
}

struct Row: View {
    let item: MenuItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
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
                    Text("\(item.description)")
                            .frame(maxHeight: 50)
                }
            }
        }

    }
}

struct DetailView: View {
    var item: MenuItem

    var body: some View {
        HStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if(!item.thumbnailUrl.isEmpty) {
                        CustomImageView(
                                props: CustomImageViewProperty(
                                        urlString: item.thumbnailUrl,
                                        width: UIScreen.main.bounds.width,
                                        height: 300)
                        )
                    }
                    Text(item.title).bold().padding()
                    Text(item.body).padding()
                    Spacer()
                }.padding()
            }
            Spacer()
        }

    }
}

struct ContentView: View {
    @StateObject private var network = RequestAPI.shared
    @State var selectedTag: Int? = nil
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(network.menuItems, id: \.id) { result in
                        NavigationLink(
                            destination: DetailView(item: result)
                        ){
                            Row(item: result)
                        }
                    }
                }.listStyle(.plain)
            }
        }.onAppear {
            network.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CatDto: Codable {
    var id: Int
    var thumbnailUrl: String
    var title: String
    var body: String
    var description: String
}

// 이건 사실 디비용
struct CatModel {
    var id: Int
    var thumbnailUrl: String
    var title: String
    var body: String
    var description: String
}

class CatConverter {
    // 모델 컨버터 자동으로 해주는 모듈이 없나?
    static func convert(catDto: CatDto) -> CatModel {
        CatModel(
                id:catDto.id,
                thumbnailUrl: catDto.thumbnailUrl,
                title: catDto.title,
                body: catDto.body,
                description: catDto.description)
    }

    static func convert(model: CatModel) -> MenuItem{
        MenuItem(
                id:model.id,
                thumbnailUrl: model.thumbnailUrl,
                title: model.title,
                body: model.body,
                description: model.description)
    }
}

class RequestAPI: ObservableObject {
    static let shared = RequestAPI()
    private init() { }

    // 이거 다 분리 해야함..
    @Published var menuItems = [MenuItem]()

    // 여기두 다 분리 해야함
    func fetchData(){
        guard let url = URL(string: "https://raw.githubusercontent.com/JoHwanhee/swift-ui-study/main/test.data.json") else{
            return
        }

        let session = URLSession(configuration: .default)

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
                self.menuItems = []
                return
            }
            guard let data = data else{
                return
            }
            do{
                let apiResponse = try JSONDecoder().decode([CatDto].self, from: data)
                DispatchQueue.main.async {
                    let catModels = apiResponse.map({dto in CatConverter.convert(catDto: dto)})
                    let menuItems = catModels.map({model in CatConverter.convert(model: model) })
                    self.menuItems = menuItems
                }
            }catch(let err){
                print(err.localizedDescription)
            }
        }
        task.resume()
    }
}