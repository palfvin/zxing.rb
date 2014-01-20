require 'rspec/core/formatters/progress_formatter'

class PryOnFirstFailure < RSpec::Core::Formatters::ProgressFormatter
  def example_failed(example)
    super(example)
    @output.puts "Debugging after first failure"
    binding.pry
  end
end