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

<style>
.ok {
  background-color: #5CB85C;
  color: #FFF;
}

.nok {
  background-color: #D9534F;
  color: #FFF;
}

.na {
  background-color: #777;
  color: #FFF;
}

.ok a {
  color: #FFF;
}
.nok a {
  color: #FFF;
}
.na a {
  color: #FFF;
}


</style>

<table>
<tr>
  <th>Name</th><th>Repository</th><th>Travis-CI</th>
</tr>
HTML

count = 0
data.reverse.each do |e|
    html += "<tr>"

    html += "<td><a href=\"https://rubygems.org/gems/#{e['name']}\">#{e['name']}</a></td>"

    if ( e['repository_url'] )
        html += "<td class=\"ok\"><a href=\"#{e['repository_url']}\">VCS</a></td>"
    else
        html += "<td class=\"nok\">Add!</td>"
    end

    m = %r{^https?://github.com/(.*)}.match(e['repository_url'])
    if ( e['travis_yml'])
        html += "<td class=\"ok\"><a href=\"https://travis-ci.org/#{m[1]}/\">Travis</a></td>"
    else
        if (e['repository_url'] and m)
            html += "<td class=\"nok\"><a href=\"https://travis-ci.org/#{m[1]}/\">Enable!</a></td>"
        else
            html += "<td class=\"na\">Irrelevant</td>"
        end
    end

    html += "</tr>\n"
	count += 1
	break if count >= 50 
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

