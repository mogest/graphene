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
            [Time.local(2010, 10, 6), 6.3]]

output = chart.render_with_canvas(Graphene::DebugCanvas.new(chart))
puts output.output
