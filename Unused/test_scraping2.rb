# frozen_string_literal: true

# tinkering with the example code that Charlie showed us

require 'mechanize'
require 'json'
require 'debug'

agent = Mechanize.new
osu_page = agent.get 'http://www.osu.edu'
dining = osu_page.link_with(text: /Dining Services/).click
hours = dining.link_with(text: /Hours/).click
nutrition = dining.link_with(text: /nutrition/i).click
netnutrition = nutrition.link_with(text: /Menus/).click
# From observing network traffic, reverse-engineered the following (for Oxley's)
oxleys = agent.post 'https://dining.osu.edu/NetNutrition/1/Unit/SelectUnitFromUnitsList', { unitOid: 27 }

# binding.break # useful for debugging

menu = JSON.parse oxleys.content
menu_html = Nokogiri::HTML(menu['panels'][0]['html'])
items = menu_html.css('.cbo_nn_itemHover')
(0...items.size).each do |i|
  item = items[i]['onkeyup'][/event,(.*)\)/, 1]  # get the id of 4th item in the menu
  label = agent.post 'https://dining.osu.edu/NetNutrition/1/NutritionDetail/ShowItemNutritionLabel', { detailOid: item }
  calories = label.css('.font-22')

  puts "#{items[i].text} has #{calories.text} calories"
end
