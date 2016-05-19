# encoding: utf-8
module HomepageSteps
  step %(:pageページにアクセスする) do |page|
    visit "#{page}"
  end

  step "画面に地図が表示されていること" do
    except(page).to have_content("#map")
  end
end

RSpec.configure { |c| c.include HomepageSteps }
