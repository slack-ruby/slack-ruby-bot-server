# see https://groups.google.com/forum/#!msg/mongoid/MaXFVw7D_4s/T3sl6Flg428J
module BSON
  class ObjectId
    def as_json(_options = {})
      to_s
    end

    def to_bson_key(encoded = ''.force_encoding(BINARY))
      to_s.to_bson_key(encoded)
    end
  end
end
