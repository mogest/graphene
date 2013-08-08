require "graphene"

#chart = Graphene::HorizontalChart.new; chart.x_axis.value_labels.padding_left = 50
chart = Graphene::Chart.new
chart.name = "Graphene Feature Test"
chart.width = 1024
chart.style do
  text { font_family "Tahoma" }
  selector(".serif") { font_family "serif" }
end
chart.style.text { text_size "8px" }
chart.style.text "font-weight", "bold"

chart.legend.padding_left = 150
chart.legend.padding_bottom = 12

chart.x_axis.name = "Date"
chart.x_axis.ticks = 6
chart.x_axis.value_labels.formatter = lambda {|v| v.strftime("%e %b %Y")}
chart.x_axis.value_labels.color = '#575757'

chart.y_axis.name = "Awesomeness"
chart.y_axis.ticks = 6
chart.y_axis.grid_ticks = 11
chart.y_axis.value_labels.formatter = "%0.1f"
chart.y_axis.value_labels.color = '#575757'
#chart.y_axis.min = -10
#chart.y_axis.max = 20

chart.y2_axis.name = "Temperature"
chart.y2_axis.value_labels.formatter = "%0.2f"
chart.y2_axis.ticks = 11

chart.plot [[Time.local(2010, 9, 1), 10.0],
            [Time.local(2010, 10, 1), -2.3],
            [Time.local(2010, 11, 1), 9.871]] do |plot|
  plot.name = "Apple Pie"
  plot.stroke_colour = "green"
  plot.stroke_width = 4
  plot.fill_colour = "#77ff77"
  plot.fill_opacity = 0.1
end

chart.plot [[Time.local(2010, 9, 1), 0],
            [Time.local(2010, 10, 15), 7.1],
            [Time.local(2010, 10, 6), 6.3]] do |plot|
  plot.name = "Cream Buns"
  plot.marker = "O"
  plot.fill_colour = "#ff7777"
  plot.fill_opacity = 0.5
end

chart.plot [[Time.local(2010, 9, 1), 18],
            [Time.local(2010, 10, 1), 19],
            [Time.local(2010, 11, 1), 21]] do |plot|
  plot.axis = :y2
  plot.name = "Temperature"
  plot.stroke_colour = "blue"
  plot.stroke_width = 2
end

chart.histogram [10, -3, 15, 18, 9], Time.local(2010, 9, 1), 14 * 86400,
  :name => "Cheese demand",
  :fill_opacity => 0.2

#output = chart.render_with_canvas(Graphene::Canvases::Debug.new(chart))
#puts output.output

svg = chart.to_svg
puts svg
File.open("test.svg", "w") {|f| f.write svg}
`open test.svg`

