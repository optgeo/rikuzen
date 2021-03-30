while gets
  r = $_.strip.split(',')
  color = [r[4], r[5], r[6]].map {|v| (v.to_f / 256).round.to_s(16)}
  color = "##{color.join}"
  print "#{r[0]} #{r[1]} #{r[2]} #{r[3]} #{color}\n"
end

