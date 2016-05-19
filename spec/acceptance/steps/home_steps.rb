# encoding: utf-8
require_relative "common_steps"
module HomeSteps
  include CommonSteps

  step "画面に地図が表示されている" do
    expect(page).to have_content("Leaflet")
  end

  step "APIリンクをクリックする" do
    find(:xpath, "//a[@href='/api']").click
  end

  step "Open Park APIと表示されている" do
    expect(page).to have_content("Open Park API")
  end
end

RSpec.configure { |c| c.include HomeSteps, :home => true }
