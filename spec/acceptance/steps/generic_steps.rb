# encoding: utf-8
step %(:pageページにアクセスする) do |page|
  visit page
end

step %(:linkをクリックする) do |link|
  visit link
end
