require 'rails_helper'
Dir.glob("spec/acceptance/steps/**/*steps.rb") { |f| load f, true }
