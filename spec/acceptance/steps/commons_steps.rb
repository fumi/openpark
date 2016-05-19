# encoding: utf-8
module GenericSteps
  step %(:pageページにアクセスする) do |page|
    visit page
  end

  step %(:linkリンクをクリックする) do |link|
    visit link
  end
end

RSpec.configure { |c| c.include GenericSteps }
