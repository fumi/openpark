require 'spec_helper'

describe 'Home' do
  specify 'Visit page' do
    visit root_path
    expect(page).to have_css('a.navbar-brand', text: 'Open Park')
  end
end
