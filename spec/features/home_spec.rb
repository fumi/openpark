require "spec_helper"

describe "Home" do
  scenario "Visiting the home page" do
    visit root_path
    expect(page).to have_content "Open Park"
  end

end
