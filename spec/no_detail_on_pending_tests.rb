# Skip detail on pending tests.

module NoDetailOnPendingTests
  def dump_pending(*); end
end

RSpec::Core::Formatters::ProgressFormatter.prepend(NoDetailOnPendingTests)
RSpec::Core::Formatters::DocumentationFormatter.prepend(NoDetailOnPendingTests)
