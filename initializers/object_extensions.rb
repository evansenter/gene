class Object
  def returning(value)
    yield value
    value
  end
  
  def send_if(condition, method, *arguments)
    block = arguments.pop if arguments.last.is_a?(Proc) && arguments.length == 1
    if condition
      block ? eval("self.#{method} &block") : self.send(method, *arguments)
    else
      self
    end
  end

  def assert_at_least(number_required, number_present, message = nil)
    unless number_present >= number_required
      raise(ArgumentError, message || "You must provide at least #{number_required} objects (#{number_present} #{number_present == 1 ? 'was' : 'were'} provided)")
    end
  end
  
  def class_metaclass
    class << self.class; self; end
  end
end