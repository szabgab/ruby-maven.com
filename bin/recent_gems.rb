require 'open-uri'
require 'json'
require 'pp'

url = 'https://rubygems.org/api/v1/activity/just_updated.json'

def get(url, params = {})
    #params ||= {}
    params["User-Agent"] ||= "Code-Maven (see: http://code-maven.com/ )"
    puts "-> Fetching #{url}"
    #pp params
    fh = open(url, params)
    return fh.read
end

def get_travis_status(builds)
    #puts 'get_travis_status'
    #puts builds

    return 'unknown' unless builds
    state = builds[0]['state']
    #puts 'state: ' + state

    return state     if /cancel|pend/ =~ state
    return 'error'   if /error/ =~ state
    return 'failing' if /fail/  =~ state
    return 'passing' if /pass/  =~ state
    return 'unknown'
end


response = get(url)
gems = JSON.parse(response)
#pp gems

recent = []

gems.each do |g|
    #puts g['name']
    #puts g['homepage_uri']
    item = {
       'name' => g['name'],
    }
    if (not g['homepage_uri'])
        item['error'] = 'homepage_url missing'
        recent.push(item)
        next
    end
    item['homepage_uri'] = g['homepage_uri']
    m = %r{^https?://github.com/(.*)}.match(item['homepage_uri'])
    if (not m)
        item['error'] = 'homepage_uri is not to github'
        recent.push(item)
        next
    end

    #puts m[1]

    # check in cache?

    # check Github for a Travis-CI file
    # and what if they don't use master as their primary branch?
    travis_yml_url = 'https://raw.githubusercontent.com/' + m[1] + '/master/.travis.yml'
    begin
       travis_yml = get(travis_yml_url)
    rescue
       #puts 'No travis.yml fund'
    end
    if (not travis_yml)
        item['error'] = 'no travis.yml found in git repository'
    end

    travis_url = 'https://api.travis-ci.org/repos/' + m[1] + '/builds';
    res = get( travis_url, {'Accept' => 'application/vnd.travis-ci.2+json'})
    #puts res
    #puts '-----'
    data = JSON.parse(res)
    #pp data
    if (not data or not data['builds'] or data['builds'].length == 0)
        # was this a JSON parse error or was this the exception that still set travis_yml to some value?
        item['error'] = 'Could not find builds in data received from travis-ci.org'
        recent.push(item)
        next
    end

    begin
        item['travis_status'] = get_travis_status( data['builds'] )
    rescue
        puts travis_yml
        puts '---'
        pp data
        exit
    end
    recent.push(item)
    break if recent.length > 5
end

#pp recent

# save to json file
# another piece of code to generate html
f = File.new('recent.json', 'w')
f.write(JSON.generate(recent))
f.close

