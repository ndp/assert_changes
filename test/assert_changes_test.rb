require 'test/unit'
require "#{File.dirname(__FILE__)}/../lib/assert_changes.rb"

class AssertChangesTest < Test::Unit::TestCase

  include ::AssertChanges

  def test_detects_single_implicit_precondition_failure
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'true' => true do
        ;
      end
    end
  end

  def test_detects_single_explicit_precondition_failure
    assert_changes 'true' => [true, true] do
      ;
    end
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'true' => [false, true] do
        ;
      end
    end
  end

  def test_detects_multiple_implicit_precondition_failure
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'false'=>true, 'true' => true do
        ;
      end
    end
  end

  def test_detects_multiple_explicit_precondition_failure
    assert_changes 'true' => [true, true], 'false' => [false, false] do
      ;
    end
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'true' => [true, true], 'true' => [false, true] do
        ;
      end
    end
  end

  def test_detects_single_implicit_postcondition_failure
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'false' => true do
        ;
      end
    end
  end

  def test_detects_single_explicit_postcondition_failure
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'false' => [false, true] do
        ;
      end
    end
  end

  def test_detects_multiple_implicit_postcondition_failure
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'false'=>true, 'true' => true do
        ;
      end
    end
  end

  def test_detects_multiple_explicit_postcondition_failure
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'true' => [true, true], 'true' => [false, true] do
        ;
      end
    end
  end

  def test_variable_evaluation
    i = true
    assert_changes 'i' => false do
      i = false
    end
    assert !i

    j = false
    assert_changes 'j' => true do
      j = true
    end
    assert j
  end

  def test_no_change_means_no_change
    assert_changes 'true' => :no_change do
      ;
    end
    assert_changes 'false' => :no_change do
      ;
    end
    assert_changes '1' => :no_change do
      ;
    end
  end

  def test_no_changes
    i = 'hello'
    assert_no_changes 'i' do
      i = 'hello'
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_no_changes 'i' do
        i = 'goodbye'
      end
    end
  end

  def test_no_changes_with_value
    i = 'hello'
    assert_no_changes 'i'=>'hello' do
      i = 'hello'
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_no_changes 'i'=>'hello' do
        i = 'goodbye'
      end
    end
    i = 'hello'
    assert_raises Test::Unit::AssertionFailedError do
      assert_no_changes 'i'=>'goodbye' do
        i = 'hello'
      end
    end
  end

  def test_no_changes_array
    i, j = 'hello', 'hi'
    assert_no_changes ['i', 'j'] do
      k = 'hello'
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_no_changes ['i', 'j'] do
        j = 'goodbye'
      end
    end
  end

  def test_no_changes_with_hash
    i, j = 'hello', 'hi'
    assert_no_changes 'i'=>'hello', 'j'=>'hi' do
      i = 'hello'
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_no_changes 'i'=>'hello', 'j'=>'hi' do
        i = 'goodbye'
      end
    end

    j = 'precondition failure'
    assert_raises Test::Unit::AssertionFailedError do
      assert_no_changes 'i'=>'hello', 'j'=>'hi' do
        i = 'hello'
      end
    end
  end


  def test_nil_transitions
    i  = nil
    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'i' => nil do
      end
    end

    i = 5
    assert_changes 'i' => nil do
      i = nil
    end
    i = 5
    assert_changes 'i' => [5, nil] do
      i = nil
    end
  end


  def test_any_change_implicit
    i = 3
    assert_changes 'i' do
      i = 4
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'i' do
      end
    end
  end

  def test_any_change_explicit
    i = 3
    assert_changes 'i' => :any_change do
      i = 4
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_changes 'i' =>  :any_change  do
        i = 4
      end
    end
  end

  def test_any_change_array
    i = 3
    j = 'a'
    assert_changes ['i','j'] do
      i = 4
      j = 'b'
    end

    assert_raises Test::Unit::AssertionFailedError do
      assert_changes ['i','j'] do
        i = 4
      end
    end
  end

end