
module Tekala
  class Admin

    def params_string(hash, except = '')
      str = ''
      hash.each do |key, val|
        next if val.to_s.empty? || except == key
        str+="&#{key}=#{val}"
      end
      str
    end

    def send_picture(temp, ext, prefix)
      target = "images/#{prefix}#{ext}"
      if File.open('public/'+target, 'wb') {|f| f.write temp.read }
        target
      end
    end

    def upload_qiniu(key, filename)
      #构建上传策略
      put_policy = Qiniu::Auth::PutPolicy.new(CustomConfig::QINIUBUCKET)

      #生成上传 Token
      uptoken = Qiniu::Auth.generate_uptoken(put_policy)

      #要上传文件的本地路径
      filePath = 'public/'+key

      #调用upload_with_token_2方法上传
      code, result, response_headers = Qiniu::Storage.upload_with_token_2(
          uptoken,
          filePath,
          filename
      )
      result
    end
  end
end