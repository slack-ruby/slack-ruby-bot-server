class Team
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token, type: String
  index({ token: 1 }, unique: true)
end
