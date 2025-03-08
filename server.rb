require 'sinatra'
require 'json'
require 'securerandom'

ARTICLES_JSON ='articles.json'

#charger la liste des articles depui le fichier json s'il existe sinon on cree un tableau d'article vide
def load_articles()
  if File.exist?(ARTICLES_JSON)
    #file.read lit le contenu du fichier json et la retourne sous forme de chaine de caracteres et parse convertit
    # la chaine json en un objet ruby comme un array ou un hash
    articles = JSON.parse(File.read(ARTICLES_JSON)) 
  else
    articles=[]
  end
end

#sauvergarder les articles dans le fichier JSON
def save_articles(articles)
  #pretty_generate fait le contraire de parse,elle convertit le tableau d'article en une chaine de caracteres au format JSON
  #file.write enregistre ou ecrit la chaine json genereé dan le fichier
  File.write(ARTICLES_JSON,JSON.pretty_generate(articles))
end

get '/'do
@articles=load_articles
erb:'index'
end

get '/create' do
  erb:'create'
end

#creation d'un article
  post '/articles/create' do
    articles = load_articles
    new_article =
    {
      "id"=> SecureRandom.uuid,
      "titre"=> params[:inputTitre],
      "contenu"=> params[:inputContenu]
    }
    articles.push(new_article)
    save_articles(articles)
    redirect '/'
  end

  #afficher le formuaire d'edition d'un article
get '/articles/:id/edit' do 
  articles = load_articles
  @article = articles.find { |a| a["id"]==params[:id]}
  if @article
    erb:'edit'
  else
    "Article non trouvé"
  end
end

#modifie un article
put '/articles/:id' do
  articles=load_articles
  article=articles.find { |a| a["id"]==params[:id]}
  if article
    article["titre"]=params[:inputTitre]
    article["contenu"]=params[:inputContenu]
    save_articles(articles)
    redirect "/"
  else
    "article non trouvé"
  end
end

#supprimer un article
delete '/articles/:id' do
  articles=load_articles
  articles.reject! { |a| a["id"]==params[:id]}
  save_articles(articles)
  redirect '/'
end