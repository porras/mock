def it(description, file = __FILE__, line = __LINE__)
  return if Spec.aborted?
  return unless Spec.matches?(description, file, line)

  Spec.formatter.before_example description

  begin
    Spec.run_before_each_hooks
    yield
    Spec::RootContext.report(:success, description, file, line)
  rescue ex : Spec::AssertionFailed
    Spec::RootContext.report(:fail, description, file, line, ex)
    Spec.abort! if Spec.fail_fast?
  rescue ex
    Spec::RootContext.report(:error, description, file, line, ex)
    Spec.abort! if Spec.fail_fast?
  ensure
    begin
      Spec.run_after_each_hooks
    rescue ex : Spec::AssertionFailed
      Spec::RootContext.report(:fail, description, file, line, ex)
      Spec.abort! if Spec.fail_fast?
    rescue ex
      Spec::RootContext.report(:error, description, file, line, ex)
      Spec.abort! if Spec.fail_fast?
    end
  end
end
