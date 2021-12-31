import SwiftUI

func forTrailingZero(temp: Double) -> String {
    let tempVar = String(format: "%g", temp)
    return tempVar
}

struct ContentView: View {
    @StateObject var ytFetcher = YTFetcher()
    

    var body: some View {
        if ytFetcher.isLoading{
           Text("Loading ...")
           ProgressView()
        }else if ytFetcher.errorMessage != nil{
            Text("Thing have hit the fan")
        }else{
            NavigationView{
                List(ytFetcher.moviesList){ movie in
                    NavigationLink{
                        ScrollView{
                            
                            AsyncImage(url: URL(string: movie.largeCoverImage)){ image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 400, height: 500)
                            
                            Text(movie.descriptionFull)
                                .padding()
                                .navigationTitle("🍿 \(movie.title)")
                
                        }
                        
                    }label:{
                        HStack{
                            AsyncImage(url: URL(string: movie.mediumCoverImage)){ image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 75)
                            
                            Text(movie.title)
                            Spacer()
                            Text(" ✨ \(forTrailingZero(temp: movie.rating))")
                        }
                    }
                }
                .navigationTitle("🎬 Movies List")
                }
               
            }
            
        }
    }

class YTFetcher : ObservableObject{
    @Published var moviesList = [Movie]()
    @Published var isLoading:Bool = false
    @Published var errorMessage:String? = nil
    
    init(){
        getData()
    }
    
    func getData(){
        self.isLoading = true
        let urlString = "https://yts.mx/api/v2/list_movies.json?limit=50"
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let mynewDecoder = JSONDecoder()
            if let data = data {
                do{
                    let ytResponse = try mynewDecoder.decode(YTResponse.self, from: data)
                   
                    //Some stuff about not running updates on background threads
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.moviesList = ytResponse.data.movies
                    }
                }catch{
                
                }
            }
        }.resume()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.portrait)
    }
}
