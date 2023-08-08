require_relative './test_helper.rb'

Dir.glob('test/*_test.rb') do |_|
  puts _
  require_relative '../' + _
end

