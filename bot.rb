require 'telegram/bot'
require 'nokogiri'
require 'open-uri'
require 'uri'


token = '210582765:AAHnILFl0EIgxadw9bB6yJP090AGGwJqOS4'

digits = Array.new()
digits[0] = '0⃣'
digits[1] = '1⃣'
digits[2] = '2⃣'
digits[3] = '3⃣'
digits[4] = '4⃣'
digits[5] = '5⃣'
digits[6] = '6⃣'
digits[7] = '7⃣'
digits[8] = '8⃣'
digits[9] = '9⃣'



Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
      when '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
      when '/privet'
        bot.api.send_message(chat_id: message.chat.id, text: 'Привет чувачок!')
      when '/news'
        control = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [['/news'],['/start']], one_time_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: 'Новости', reply_markup: control)
      when '/stop'
        kb = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
        bot.api.send_message(chat_id: message.chat.id, text: 'Bye!', reply_markup: kb)
      end
    if message.text =~ %r(^/ykt\s(.+)$)
      query = URI.escape(%r(^/ykt\s(.+)$).match(message.text).captures[0])
      doc = Nokogiri::HTML(open("http://doska.ykt.ru/posts?query=#{query}"))
      i = 0
      doc.css('div.d-post').each do |post|
        i = i + 1
        bot.api.send_message(chat_id: message.chat.id, text: digits[i] + ' ' + post.css('.d-post_desc').text) if post.css('.d-post_desc').text.size > 0
        bot.api.send_message(chat_id: message.chat.id, text: post.css('.d-post_price').text) if post.css('.d-post_price').text.size > 0
        bot.api.send_message(chat_id: message.chat.id, text: post.css('.d-post_phone').text.delete(' ')) if post.css('.d-post_phone').text.size > 0

        if ("/media/img/desktop2015/default_img.png" != post.css('.d-post_img img').attr('src').to_s)
          open(post.css('.d-post_img img').attr('src').to_s) { |f|
            File.open("temp.jpg", "wb") do |file|
              file.puts f.read
            end
          }
          bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new('temp.jpg', 'image/jpeg'))
        end
        break if i == 5
      end
    end

  end
end
