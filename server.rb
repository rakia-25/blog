require 'sinatra'
enable :method_override
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

#Page d'acceuil
get '/' do
  erb:'accueil'
end

#affiche la liste de tout les articles
get '/articles' do
  @articles=load_articles()
  erb:'articles'
end

#affiche le formulaire de création d'un article
get '/create' do
  erb:'new_article'
end

#creation d'un article
post '/articles/create' do
  articles = load_articles()
  new_article =
  {
    "id"=> SecureRandom.uuid,
    "titre"=> params[:inputTitre],
    "contenu"=> params[:inputContenu],
    "comments" => []
  }
  articles.push(new_article)
  save_articles(articles)
  redirect '/articles'
end

#Creation des commentaires d'un article
post '/articles/:id/comments' do
  articles = load_articles()
  @article = articles.find { |a| a["id"]==params[:id]}
  if @article
    new_comment =
    {
      "id"=> SecureRandom.uuid,
      "message"=> params[:inputComment]
    }
    @article["comments"] << new_comment
    save_articles(articles)
  end
  redirect "/articles/#{params[:id]}"
end

#details d'un article
get '/articles/:id' do
  articles = load_articles
  @article = articles.find { |a| a["id"]==params[:id]}
  erb:'show'
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
    redirect "/articles"
  else
    "article non trouvé"
  end
end

#supprimer un article
delete '/articles/:id' do
  articles=load_articles
  articles.reject! { |a| a["id"]==params[:id]}
  save_articles(articles)
  redirect '/articles'
end

#afficher le formuaire d'edition d'un commentaire
get '/articles/:id_article/:id_comment/edit' do
  articles = load_articles()
  @article = articles.find { |a| a["id"]==params[:id_article]}
  if @article
    @comment = @article["comments"].find{|c| c["id"]==params[:id_comment]}
    if @comment
      erb:'edit_comment'
    else 
      puts "ommentaire non trouvé"
    end
  else
    puts "article non trouvé"
  end
end

put '/articles/:id_article/comments/:id_comment' do
  @articles = load_articles
  @article = @articles.find { |a| a["id"] == params[:id_article] }

  if @article
    @comment = @article["comments"].find { |c| c["id"] == params[:id_comment] }
    
    if @comment
      @comment["message"] = params[:inputMessage]  # Vérifier le nom du champ dans le formulaire
      save_articles(@articles)
      redirect "/articles/#{params[:id_article]}"
    else
      halt 404, "Commentaire non trouvé"
    end
  else
    halt 404, "Article non trouvé"
  end
end

#supprimer un commentaire
delete '/articles/:id_article/comments/:id_comment' do
  @articles=load_articles
  @article = @articles.find { |a| a["id"] == params[:id_article] }
  if @article
    @article["comments"].reject! { |c| c["id"]==params[:id_comment]}
    save_articles(@articles)
    redirect "/articles/#{params[:id_article]}"
  end
end
