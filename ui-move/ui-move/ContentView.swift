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

    @Binding var isCellSelected: Int?

    var body: some View {

        HStack {
            ScrollView() {


            VStack(alignment: .leading) {
                if(!item.thumbnailUrl.isEmpty) {
                    CustomImageView(
                            props: CustomImageViewProperty(
                                    urlString: item.thumbnailUrl,
                                    width: UIScreen.main.bounds.width,
                                    height: 300)
                    )
                }

                //Spacer()
                Text(item.title).bold().padding()

                Text(item.body).padding()

                Spacer()
//            Button("Back") {
//                isCellSelected = nil
//            }
            }.padding()
            }
            Spacer()
        }

    }
}

struct ContentView: View {
    @State var selectedTag: Int? = nil

    var body: some View {
        let items = [
            MenuItem(thumbnailUrl: "https://ww.namu.la/s/8937c9d1bdcd8114327151a3cd075ed21ebaae13d1145d67aacad76389fa91736e3e096066cd10fc965a3ae118404ae6204fc06314409a5b4f2758c797b8a942fb845e7cb4dcc80b95fbb7fc5ba0b9e6aad73be77cb5533624de1e3352a59cf7",
                    title: "페르시안", body: "\n페르시아에서 오래 전부터 사육되어 오던 고양이가 16세기 즈음 유럽에 전래된 것이 시초로 둥근 얼굴, 짧은 다리, 그리고 털이 긴 것이 특징이다. 무게는 보통 4~5kg 정도로 생김새와 크기가 시추와 비슷하다.\n\n우리나라에서 키우는 고양이 중 긴 털을 가진 고양이는 대개 이 페르시안이나 도메스틱 롱헤어 혹은 숏헤어등이 섞인 혼혈종이다.\n\n얼굴이 크게 두 종류가 있는데, 하나는 일반 고양이처럼 생긴 것이고(클래식 또는 돌페이스 또는 트래디셔널) 또 하나는 마치 개의 퍼그나 불독처럼 코가 들린 것(페키 페이스[1] 또는 익스트림)이다. 대체로 우리나라에서 볼 수 있는 것은 일반 고양이처럼 생긴 트래디셔널. 하지만 일반 고양이처럼 생겼다고 하더라도 보통의 고양이에 비하면 페르시안 쪽이 얼굴이 좀 더 둥글넙적한 편. 또한 귀(페르시안의 귀는 새끼고양이처럼 작고 귀 사이의 거리가 멀다), 체형(터키쉬 앙고라는 늘씬한 포린 체형이지만 페르시안은 대두에 오동통하고 숏다리인 코비 체형), 털(페르시안의 털이 좀 더 길다)의 차이도 있는데, 얼굴로 분간하는 게 가장 쉽다.\n\n트래디셔널 얼굴이 생기는 이유는 첫 번째로 근대 유럽에서 페르시안과 타 장모종의 분별없는 교배가 성행한 탓에 현대의 순종 페르시안이어도 다른 품종의 유전자가 남아있는 경우가 많아서이고, 두 번째로 현대에 태어난 잡종이다.\n\n전체적으로 고양이 중 조용하고 성격도 순한 편이다. 장모종 중에서도 부드러우면서도 가는 속털을 가진 이중모로 인해 털의 부드러움으로서는 최고이지만, 이는 반대로 털빠짐이 많은 고양이 중에서도 최고를 자랑한다는 걸 뜻하므로 털은 열심히 빗겨줘야 한다.[2] 제대로 빗겨주지 않을 경우 털빠짐은 물론이고, 부드러운 속털끼리 엉켜서 고양이도 아프고, 사람도 불편한 사태가 발생한다.\n\n워낙 인기가 많은 고양이 중 하나라 같은 페르시안이라도 또 다시 여러 종류가 있다. 당장 위의 들창코 비교 사진만 봐도 과연 저 둘이 같은 고양이 품종일까 싶을 정도로 다르게 생겼지만, 일단은 둘 다 페르시안.\n\n하얀 페르시안은 정말 아름답고 순해보인다. 당연히 입양할 때 드는 가격도 상당하다. 어떤 동물 프로그램에서 다른 집고양이들이 만만하게 보고 시비를 걸다 저 고양이가 털을 세우자 인상이 180도 바뀌었는데 시비걸던 집고양이들이 놀라서 도망쳤다.팝콘 털 세울 때만큼은 가장 무섭게 변하는 고양이이다.\n\n하위종으로 다음과 같은 종들이 있다.", description: "페르시아에서 오래 전부터 사육되어 오던 고양이가 16세기 즈음 유럽에 전래된 것이 시초로 둥근 얼굴, 짧은 다리, 그리고 털이 긴 것이 특징이다. 무게는 보통 4~5kg 정도로 생김새와 크기가 시추와 비슷하다."),
            MenuItem(thumbnailUrl:"https://mblogthumb-phinf.pstatic.net/20160412_232/sucard_1460426525347yg5k7_JPEG/bgq_6443.jpg?type=w2", title: "뱅골", body: "벵골 고양이는 국내 고양이, 특히 점박이 이집트 마우와 아시아 표범 고양이의 잡종으로 만든 길 들여진 고양이 품종입니다. 품종 이름은 표범 고양이의 분류 학적 이름에서 유래합니다. 벵골은 야생의 모습을하고 있습니다.", description: "벵골 고양이는 국내 고양이, 특히 점박이 이집트 마우와 아시아 표범 고양이의 잡종으로 만든 길 들여진 고양이 품종입니다. 품종 이름은 표범 고양이의 분류 학적 이름에서 유래합니다. 벵골은 야생의 모습을하고 있습니다."),
            MenuItem(thumbnailUrl:"https://ww.namu.la/s/ebbd5cbfc79acf7669b07abda37d4be408ba1a9875085b00ee7849e5f91f45e80111868c7dd5fcf8afe62cb792db61e0473d89818173bc837d3e905342d3932ead9a84d42988de6c3f7503c83ad9d6c3becc3d934794d9012bca18ea5ff0c07b", title: "스코티시 폴드", body: "고양이의 품종 중 하나. 후술할 유전병 문제의 심각함에도 불구하고 땅딸막한 외모가 귀엽다는 이유로 계속 브리딩되고 있는 인기 품종 중 하나이다. 스코티시는 영국 스코틀랜드 출신을 의미하고 폴드는 접힌 것. 즉 귀가 접혔다는 것을 의미한다.\n\n모든 스코티시 폴드는 1961년 스코틀랜드의 한 농장에서 태어난 돌연변이 고양이 Susie의 후손이다. 귀가 접혀있는 모습이 귀여워서 이후 20년 동안 브리티시 숏헤어 및 아메리칸 숏헤어와 교배되는 과정을 거쳐 새로운 품종으로 자리를 잡았다.\n\n하지만 인위적인 근친교배의 결과 골연골 이형성증 유전병을 타고나는 개체가 많아 악명높은 품종이다. 이 때문에 정작 영국협회에서는 스코티시 폴드의 품종등록을 거부했다.", description: "고양이의 품종 중 하나. 후술할 유전병 문제의 심각함에도 불구하고 땅딸막한 외모가 귀엽다는 이유로 계속 브리딩되고 있는 인기 품종 중 하나이다. 스코티시는 영국 스코틀랜드 출신을 의미하고 폴드는 접힌 것. 즉 귀가 접혔다는 것을 의미한다.\n\n모든 스코티시 폴드는 1961년 스코틀랜드의 한 농장에서 태어난 돌연변이 고양이 Susie의 후손이다. 귀가 접혀있는 모습이 귀여워서 이후 20년 동안 브리티시 숏헤어 및 아메리칸 숏헤어와 교배되는 과정을 거쳐 새로운 품종으로 자리를 잡았다.\n\n하지만 인위적인 근친교배의 결과 골연골 이형성증 유전병을 타고나는 개체가 많아 악명높은 품종이다. 이 때문에 정작 영국협회에서는 스코티시 폴드의 품종등록을 거부했다.")
        ]

        NavigationView {
            ZStack {
                ForEach(items.indices) {
                    index in NavigationLink(
                            destination:
                            DetailView(item: items[index],
                                    isCellSelected: $selectedTag),
                            tag: index,
                            selection: $selectedTag,
                            label: {
                                EmptyView()
                            })

                }

                List {
                    ForEach(items.indices) {
                        index in Button(action: {
                            selectedTag = index
                            print(selectedTag)
                        }) {
                            Row(item: items[index])
                        }
                    }
                }.listStyle(.plain)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}