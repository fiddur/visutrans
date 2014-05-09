require_relative 'models/init'

filename = ARGV[0]

#require 'rubyXL'
#book = RubyXL::Parser.parse(filename)

require 'simple-spreadsheet'
book = SimpleSpreadsheet::Workbook.read(filename)

sheet = book.sheets.first

line_no = 0

book.first_row.upto(book.last_row) do |line|
  line_no = line_no + 1

  next unless(line_no > 5)

  bookkept_at     = Date.parse(book.cell(line, 1))
  payment_date    = Date.parse(book.cell(line, 2))
  verification    = book.cell(line, 3)
  recipient_text,foo_date = book.cell(line, 4).strip.split('/').map{|s| s.strip}
  amount          = book.cell(line, 5)

  if amount > 0
    direction = 'incoming'
  else
    direction = 'outgoing'
    amount = -amount
  end

  # Try to find recipient
  recipient_desig = Recipient_Desig.find(recipient_text: recipient_text)

  unless recipient_desig
    recipient_desig = Recipient_Desig.create(recipient_text: recipient_text)
  end

  # Try to find an already existing transaction.
  transaction = Transaction.find(
    bookkept_at:     bookkept_at.strftime('%s').to_i,
    payment_date:    payment_date.strftime('%s').to_i,
    verification:    verification,
    recipient_text:  recipient_text, # redundant...
    amount:          amount,
    direction:       direction
  )

  if transaction
    p "Found existing #{recipient_text} #{transaction.amount}."
  else
    # Create a transaction
    transaction = Transaction.create(
      bookkept_at:    bookkept_at,
      bookkept_week:  bookkept_at.year.to_s + sprintf('%02d', bookkept_at.cweek)
      payment_date:   payment_date,

      verification:   verification,
      recipient_text: recipient_text, # redundant...
      amount:         amount,
      direction:      direction
    )
    transaction.recipient_desig = recipient_desig

    p "Created #{recipient_text} #{transaction.amount}."
  end


  if recipient_desig.designates
    recipient = recipient_desig.designates
  else
    # Try generic matching

    # - like AUT\d\d.\d\d

    # WIth ICA ?

    # Bensin   STATOIL  OKQ8

    # Create recipient
    recipient = Recipient.create()
    recipient.designated_by << recipient_desig
  end

  transaction.belongs_to = recipient

  #break if(line_no > 15)
end
