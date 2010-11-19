require "graphene"

chart = Graphene::Chart.new
chart.name = "A title!"

chart.legend
chart.x_axis.name = "Date"
chart.y_axis.name = "Awesomeness"

chart.plot [[Time.local(2010, 9, 1), 10.0],
            [Time.local(2010, 10, 1), 12.3],
            [Time.local(2010, 11, 1), 9.871]]

chart.plot [[Time.local(2010, 9, 1), 0],
            [Time.local(2010, 10, 15), 7.1],
            [Time.local(2010, 10, 6), 6.3]] do |plot|
  plot.marker = "O"
end

output = chart.render_with_canvas(Graphene::Canvases::Debug.new(chart))
puts output.output

svg = chart.to_svg
puts svg
File.open("test.svg", "w") {|f| f.write svg}
`open test.svg`

