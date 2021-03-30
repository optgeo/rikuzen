MINZOOM = 11
MAXZOOM = 18
LASGRID = '/home/pi/SpatiumGL/build/bin/lasgrid'
SRC_DIR = 'src'
DST_DIR = 'dst'
SPACINGS = [6400, 3200, 1600, 800, 400, 200, 100, 50]
SITE_ROOT = 'http://m321:9966'

require 'find'

task :grid do
  SPACINGS.each {|spacing|
    meter = spacing / 100.0
    sh "rm -f #{DST_DIR}/#{spacing}*.las"
    Find.find(SRC_DIR) {|path|
      next unless /las$/.match path
      sh [
        LASGRID,
        "-i #{path}",
        "-o #{DST_DIR}/#{spacing}-#{File.basename(path)}",
        "--spacing #{meter}"
      ].join(' ')
    }
  }
end

task :produce do
  cmd = ['(']
  Find.find(DST_DIR) {|path|
    next unless /(\d*)-(.*)\.las$/.match path
    spacing, fn = [$1, $2]
    cmd.push(
      "las2txt --parse xyzcRGB -i #{path} --stdout |",
      "ruby filter1.rb |",
      "cs2cs +init=epsg:6678 +to +init=epsg:6668 -f %.11f |",
      "SPACING=#{spacing} ruby filter2.rb;"
    )
  }
  cmd.push(
    ')',
    "| tippecanoe -o tiles.mbtiles",
    "--force",
    "--hilbert",
    "--minimum-zoom=#{MINZOOM}",
    "--maximum-zoom=#{MAXZOOM}",
    "--base-zoom=#{MAXZOOM}",
    "--no-tile-size-limit",
    "--no-feature-limit",
    "--postfilter='node postfilter.js'",
    "; tile-join",
    "--force",
    "--no-tile-compression",
    "--no-tile-size-limit",
    "--output-to-directory=docs/zxy",
    "tiles.mbtiles"
  )
  sh cmd.join(' ')
end

task :style do
  sh [
    "SITE_ROOT=#{SITE_ROOT}",
    "MINZOOM=#{MINZOOM}",
    "MAXZOOM=#{MAXZOOM}",
    "parse-hocon hocon/style.conf > docs/style.json"
  ].join(' ')
  sh "gl-style-validate docs/style.json"
end

task :optimize do
  sh "node ../vt-optimizer/index.js -m tiles.mbtiles"
end

task :host do
  sh "budo -d docs"
end

