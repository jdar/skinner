# borrowed: http://pivotallabs.com/users/cheister/blog/articles/659-duplicate-test-name-detection
module MethodRegistry
  def known_test_methods
    @known_test_methods ||= Array.new
  end

  def method_added(method)
    if method.to_s.match /^test./
      if known_test_methods.include?(method)
        raise "Duplicate test #{self}##{method}"
      else
        known_test_methods << method
      end
    end
    super
  end
end