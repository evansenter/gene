module UnboundMethodExtensions
  def self.included(base)
    base.class_eval do
      alias [] bind
    end
  end
end

class UnboundMethod; include UnboundMethodExtensions; end