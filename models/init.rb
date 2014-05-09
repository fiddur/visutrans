# -*- coding: utf-8 -*-
require 'neo4j'
require 'active_support'

session = Neo4j::Session.open(:server_db, VisuTrans.neo_host)

class Recipient_Desig
  include Neo4j::ActiveNode

  property :recipient_text, type: String
  index    :recipient_text

  has_one :designates
  has_n(:transactions).from(:recipient_desig)
end

class Recipient
  include Neo4j::ActiveNode

  property :created_at

  has_n(:designated_by).from(:designates)
  has_one :belongs_to

  def name
    designated_by.map{|desig|desig.recipient_text}.join(' / ')
  end

end

class Category
  include Neo4j::ActiveNode

  property :created_at
  property :name,       type: String

  has_n(:recipients).from(:belongs_to)
end


# Monkeypatching Neo4j::Server::CypherResponse::HashEnumeration.each
module Neo4j::Server
  class CypherResponse::HashEnumeration
    def each()
      data.each do |row|
        p row
        hash = {}

        row.each_with_index do |row, i|
          hash[columns[i].to_sym] = row
        end
        yield hash
      end
    end
  end
end
module Neo4j::Server
  class Neo4jServerEndpoint
    def post(url, options={})
      #puts "Posting to #{url}: #{merged_options(options)}"
      HTTParty.post(url, merged_options(options))
    end
  end
end

class Transaction
  include Neo4j::ActiveNode

  property :bookkept_at,    type: Date
  property :bookkept_week,  type: Integer  # YYYYWW as an integer, to ease interval selection
  property :payment_date,   type: Date
  property :verification,   type: String
  property :recipient_text, type: String
  property :amount,         type: Float
  property :created_at
  property :direction,      type: String # 'incoming' or 'outgoing'

  has_one :recipient_desig
  has_one :belongs_to # recipient

  index :verification

  def self.getByDate(date)
    self.all(bookkept_at: date.strftime('%s').to_i)


    trans_nodes = Neo4j::Session.current.query(
      "MATCH (trans:Transaction) " +
      "  WHERE trans.bookkept_at = '#{date.strftime('%s').to_i}' RETURN trans"
    )

  end

  def self.sumAmountByDay(from, to)
    sums = Neo4j::Session.current.query(
      "MATCH (trans:Transaction)-->()-->()-->(cat:Category) " +
      "  WHERE trans.bookkept_at >= #{from.strftime('%s')} " +
      "    AND trans.bookkept_at <= #{to.strftime('%s')} " +
      "  RETURN cat.name, trans.bookkept_at, trans.direction, sum(trans.amount) " +
      "  ORDER BY trans.bookkept_at, trans.direction "
      )


    daysums = {}
    (from..to).each do |date|
      daysums[date.to_s.to_sym] = Hash.new(0)
    end

    for sum in sums
      date = Date.strptime(sum[:"trans.bookkept_at"].to_s, '%s').to_s.to_sym
      amount = sum[:"sum(trans.amount)"]
      amount = -amount if sum[:"trans.direction"] == 'outgoing'
      daysums[date][:sum] += amount
      daysums[date][sum[:"cat.name"].to_sym] += amount
    end

    daysums
  end

  def self.sumAmountByWeek(from, to)
    sums = Neo4j::Session.current.query(
      "MATCH (trans:Transaction)-->()-->()-->(cat:Category) " +
      "  WHERE trans.bookkept_week >= #{from.year}#{sprintf('%02d', from.cweek)} " +
      "    AND trans.bookkept_week <= #{to.year}#{sprintf('%02d', to.cweek)}    " +
      "  RETURN cat.name, trans.bookkept_week, trans.direction, sum(trans.amount) " +
      "  ORDER BY trans.bookkept_week, trans.direction "
    )


    weeksums = {}

    (from.year..to.year).each do |year|
      from_week = year == from.year ? from.cweek : 1
      to_week   = year == to.year ? to.cweek : Date.parse("#{year}-12-28").cweek

      (from_week..to_week).each do |week|
        weeksums["#{year}#{sprintf('%02d', week)}".to_sym] = { sum: 0 }
      end
    end

    p sums

    for sum in sums
      week = sum[:"trans.bookkept_week"].to_s.to_sym

      amount = sum[:"sum(trans.amount)"]
      amount = -amount if sum[:"trans.direction"] == 'outgoing'

      weeksums[week][:sum] += amount
      weeksums[week][sum[:"cat.name"].to_sym] = amount
    end

    weeksums
  end


  def self.sumAmountByMonth(from, to)
    from = from.at_beginning_of_month
    to   = to.at_end_of_month

    sums = Neo4j::Session.current.query(
      "MATCH (trans:Transaction)-->()-->()-->(cat:Category) " +
      "  WHERE trans.bookkept_at >= #{from.strftime('%s')} " +
      "    AND trans.bookkept_at <= #{to.strftime('%s')}    " +
      "  RETURN cat.name, trans.bookkept_at, trans.direction, sum(trans.amount) "
    )

    monthsums = {}

    (from.year..to.year).each do |year|
      from_month = year == from.year ? from.month : 1
      to_month   = year == to.year ? to.month : 12

      (from_month..to_month).each do |month|
        monthsums["#{year}#{sprintf('%02d', month)}".to_sym] = Hash.new(0)
      end
    end

    for sum in sums
      date = Date.strptime(sum[:"trans.bookkept_at"].to_s, '%s')

      month = "#{date.year}#{sprintf('%02d', date.month)}".to_sym

      amount = sum[:"sum(trans.amount)"]
      amount = -amount if sum[:"trans.direction"] == 'outgoing'

      monthsums[month][:sum] += amount
      monthsums[month][sum[:"cat.name"].to_sym] += amount
    end

    monthsums
  end
end
