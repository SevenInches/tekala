
module Szcgs
  class Admin

    def params_string(hash, except = '')
      str = ''
      hash.each do |key, val|
        next if val.to_s.empty? || except == key
        str+="&#{key}=#{val}"
      end
      str
    end

  end
end