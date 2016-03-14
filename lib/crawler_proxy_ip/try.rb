class Object
  def try(*a, &b)
    try!(*a, &b) if a.empty? || respond_to?(a.first)
  end

  def try!(*a, &b)
    if a.empty? && block_given?
      if b.arity == 0
        instance_eval(&b)
      else
        yield self
      end
    else
      public_send(*a, &b)
    end
  end
end

class NilClass
  def try(*args)
    nil
  end

  def try!(*args)
    nil
  end
end
