class VisuTrans
  get '/transactions' do
    'todo'
  end

  get '/transactions/day' do
    @title = "Transaction summary by day"

    # Default interval: one month ago until now
    from = params[:from] ? Date.parse(params[:from]) : Date.today.prev_month
    to   = params[:to  ] ? Date.parse(params[:to  ]) : Date.today

    @sums = Transaction.sumAmountByDay(from, to)
    @categories = Category.all

    erb :sums, layout: :default
  end

  get '/transactions/week' do
    @title = "Transaction summary by week"

    # Default interval: one year ago until now
    from = params[:from] ? Date.parse(params[:from]) : Date.today.prev_year
    to   = params[:to  ] ? Date.parse(params[:to  ]) : Date.today

    @sums = Transaction.sumAmountByWeek(from, to)
    @categories = Category.all

    erb :sums, layout: :default
  end

  get '/transactions/month' do
    @title = "Transaction summary by month"

    # Default interval: one year ago until now
    from = params[:from] ? Date.parse(params[:from]) : Date.today.prev_year
    to   = params[:to  ] ? Date.parse(params[:to  ]) : Date.today

    @sums = Transaction.sumAmountByMonth(from, to)
    @categories = Category.all

    @skip_categories = params['skip']
    p @skip_categories

    erb :sums, layout: :default
  end
end
