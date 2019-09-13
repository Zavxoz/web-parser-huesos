require_relative 'executor'

if __FILE__ == $0
  ex = Executor.new(ARGV[0], ARGV[1]+".csv")
  ex.execute
end
