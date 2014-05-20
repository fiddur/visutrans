# -*- coding: utf-8 -*-
class VisuTrans
  get '/categories/:id' do
    @category = Category.find(params[:id])

    erb :category, layout: :default
  end
end

