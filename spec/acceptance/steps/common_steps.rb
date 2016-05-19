# encoding: utf-8
module CommonSteps
  step %(:pageページにアクセスする) do |page|
    visit page
  end
end

RSpec.configure { |c| c.include CommonSteps, :common => true }
