require 'json'
require 'pp'

f = File.open('recent.json', 'r')
json_str = f.read
f.close

data = JSON.parse(json_str)

#pp data 

params = {
    'title' => 'Ruby Maven',
}

html = <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport"
     content="width=device-width, initial-scale=1, user-scalable=yes">
  <title>#{params['title']}</title>
</head>
<body>
<h1>#{params['title']}</h1>
<table>
<tr>
  <th>Name</th><th>Travis-CI</th><th>Error</th>
</tr>
HTML

data.each do |e|
    html += "<tr>"
    if ( e['homepage_uri'])
        html += "<td><a href=\"#{e['homepage_uri']}\">#{e['name']}</a></td>"
    else
        html += "<td>#{e['name']}</td>"
    end
    if ( e['travis_status'])
        html += "<td><img src=\"/img/build-#{e['travis_status']}.png\"></td>"
    else
        html += "<td>na</td>"
    end

	html += "<td>#{e['error'] ? e['error'] : '&nbsp;'}</td>";

    html += "</tr>\n"
end

html += <<HTML
</table>

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-12199211-24', 'auto');
  ga('send', 'pageview');

</script>


</body>
</html>
HTML

d = 'html'
if (not Dir.exists? d)
	Dir.mkdir d
end
fh = File.new('html/index.html', 'w')
fh.write(html)
fh.close

