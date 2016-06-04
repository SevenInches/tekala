require 'net/http'
module Submail
  def self.send_with_submail(phone, name, teacher, book_time, other_book_time)
    uri = URI('https://api.submail.cn/message/xsend.json')
    res = Net::HTTP.post_form(uri, 'appid' => '10271',
      'signature' => '0920b2700355dcf434759afed79d88ea',
      'project' => 'lDuZd3',
      'to' => phone,
      'vars' => {name: name, teacher: teacher, book_time: book_time, other_book_time: other_book_time}.to_json)
    puts res.body
  end

  def self.get_unicode_str(chr)
    chr.each_char.map{|c| "%04x" % c.ord }.join('').upcase
  end
end