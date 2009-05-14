module AssertChanges

  # Assertion that a specific state changes during invocation of the
  # passed in block.
  #
  #   i = 'simple'
  #   assert_changes 'i' => 'whacky' do
  #      i = 'whacky'
  #   end
  #
  # This can be read "assert i changes to wacky".
  # Function will verify both the precondition (i is NOT wacky),
  # and the post-condition.
  #
  # This means i becomes nil during the block (and therefore non-nil
  #  beforehand):
  #   assert_changes 'i' => nil do ...
  #
  #
  # If you want to specify a specific transition, you can do so
  # by providing an array:
  #
  #   assert_changes 'i' => ['simple','whacky'] do
  #
  # To specify that there should be no changes, use the symbol :no_change.
  #
  #   assert_changes 'i' => :no_change do
  #
  # Finally, multiple assertions can be passed for larger sets
  # of state changes:
  #
  #   i, j = 1,2
  #   assert_changes 'i' => [1, 2], 'j' => [2, 1] do
  #      Mixer.mix(i,j)
  #   end
  #
  def assert_changes(transitions, &block)
    transitions = [transitions] if transitions.class==String
    if transitions.class == Array
      h = Hash.new
      transitions.each {|i| h[i] = :any_change}
      transitions = h
    end
    transitions.each  do |expression, value|
      result = eval(expression, block.__send__(:binding))
      if value == :no_change
        transitions[expression] = [result, result]
      elsif value == :any_change
        transitions[expression] = [result, :any_change]
      elsif value.nil?
        assert_not_nil(result, "Precondition not met")
      else
        pre_value = (value.class == Array) ? value[0] : !value
        assert_equal pre_value, result, "Precondition not met: " + expression
      end
    end
    yield
    transitions.each  do |expression, value|
      final_value = (value.class == Array) ? value[1] : value
      new_value = eval(expression, block.__send__(:binding))
      if final_value == :any_change
        assert value[0] != new_value, "Any change failed for " + expression
      else
        assert_equal final_value, new_value, "Change failed for " + expression
      end
    end
  end


  def assert_no_changes(transitions, &block)
    if String === transitions
      assert_changes(transitions=>:no_change, &block)
    elsif Array === transitions
      assert_changes(transitions.inject({}) { |map, exp| map.merge(exp => :no_change) }, &block)
    else  # map
      map = {}
      transitions.each {|k, v| map[k]=[v, v]}
      assert_changes(map, &block)
    end
  end


end