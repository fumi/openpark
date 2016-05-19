# encoding: utf-8
module HomepageSteps
  step "画面に地図が表示されている" do
    expect(page).to have_content("Leaflet")
  end

  step "" do
  end
end

RSpec.configure { |c| c.include HomepageSteps }
