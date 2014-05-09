# -*- coding: utf-8 -*-
class VisuTrans
  get '/recipients/categorize' do
    recipient_ids = Neo4j::Session.current.query(
      "MATCH (n:Recipient) WHERE NOT (n)-->(:Category) RETURN ID(n) ORDER BY n.bookkept_at DESC LIMIT 10"
      )
    @recipients = []
    recipient_ids.each do |id|
      @recipients << Recipient.find(id[:"ID(n)"])
    end

    @categories = Category.all()

    erb :categorize_recipients, layout: :default
  end

  post '/recipients/categorize' do
    recipient = Recipient.find(params[:recipient])
    category  = Category.find(params[:category])

    recipient.belongs_to = category

    flash[:info] = "Added #{recipient.name} to #{category.name}"
    redirect '/recipients/categorize'
  end

end
