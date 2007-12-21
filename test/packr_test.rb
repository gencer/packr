require 'test/unit'
require 'packr'

class PackrTest < Test::Unit::TestCase
  
  def setup
    dir = File.dirname(__FILE__) + '/assets'
    @data = {
      :default => [{
        :source => File.read("#{dir}/src/controls.js"),
        :packed => File.read("#{dir}/packed/controls.js")
      }],
      :shrink => [{
        :source => File.read("#{dir}/src/dragdrop.js"),
        :packed => File.read("#{dir}/packed/dragdrop.js")
      },
      { :source => File.read("#{dir}/src/prototype.js"),
        :packed => File.read("#{dir}/packed/prototype_shrunk.js")
      }],
      :base62 => [{
        :source => File.read("#{dir}/src/effects.js"),
        :packed => File.read("#{dir}/packed/effects.js")
      }],
      :base62_shrink => [{
        :source => File.read("#{dir}/src/prototype.js"),
        :packed => File.read("#{dir}/packed/prototype.js")
      }]
    }
  end
  
  def test_basic_packing
    assert_equal @data[:default][0][:packed], Packr.pack(@data[:default][0][:source])
  end
  
  def test_shrink_packing
    assert_equal @data[:shrink][0][:packed].length, Packr.pack(@data[:shrink][0][:source], :shrink => true).length
    assert_equal @data[:shrink][1][:packed].length, Packr.pack(@data[:shrink][1][:source], :shrink => true).length
  end
  
  def test_base62_packing
    expected = @data[:base62][0][:packed]
    actual = Packr.pack(@data[:base62][0][:source], :base62 => true)
    assert_equal expected.size, actual.size
    expected_words = expected.scan(/'[\w\|]+'/)[-2].gsub(/^'(.*?)'$/, '\1').split("|").sort
    actual_words = actual.scan(/'[\w\|]+'/)[-2].gsub(/^'(.*?)'$/, '\1').split("|").sort
    assert expected_words.eql?(actual_words)
  end
  
  def test_base62_and_shrink_packing
    expected = @data[:base62_shrink][0][:packed]
    actual = Packr.pack(@data[:base62_shrink][0][:source], :base62 => true, :shrink => true)
    assert_equal expected.size, actual.size
    expected_words = expected.scan(/'[\w\|]+'/)[-2].gsub(/^'(.*?)'$/, '\1').split("|").sort
    actual_words = actual.scan(/'[\w\|]+'/)[-2].gsub(/^'(.*?)'$/, '\1').split("|").sort
    assert expected_words.eql?(actual_words)
  end
  
  def test_private_variable_packing
    script = "var _KEYS = true; (function() { var foo = _KEYS; })();"
    assert_equal "var _0=true;(function(){var a=_0})();", Packr.pack(script, :shrink => true, :private => true)
  end
  
  def test_protected_names
    expected = 'var func=function(a,b,$super,c){return $super(a+c)}'
    actual = Packr.pack('var func = function(foo, bar, $super, baz) { return $super( foo + baz ); }', :shrink => true)
    assert_equal expected, actual
    packr = Packr.new
    packr.protect_vars *(%w(other) + [:method, :names] + ['some random stuff', 24])
    expected = 'var func=function(a,other,$super,b,names){return $super()(other.apply(names,a))}'
    actual = packr.pack('var func = function(foo, other, $super, bar, names) { return $super()(other.apply(names, foo)); }', :shrink => true)
    assert_equal expected, actual
  end
  
  def test_object_properties
    expected = 'function(a,b){this.queue.push({func:a,args:b})}'
    actual = Packr.pack('function(method, args) { this.queue.push({func: method, args: args}); }', :shrink => true)
    assert_equal expected, actual
  end
end
