class Objectifier
  def initialize(hash)
    hash.each do |key, value|
      define_singleton_method(key) { value }
    end
  end
end

class Hash
  def to_fckin_object
    Objectifier.new(self)
  end
end
