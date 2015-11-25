require 'open-uri'
require 'json'
require 'pp'


def main()
    url = 'https://rubygems.org/api/v1/activity/just_updated.json'
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
		repository_url = g['source_code_uri'] || g['homepage_uri']
		if (not repository_url) 
			#pp g
            recent.push(item)
            next
        end
        item['repository_url'] = repository_url
        m = %r{^https?://github.com/(.*)}.match(repository_url)
        if (not m)
			#pp g
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
        if (travis_yml)
			item['travis_yml'] = true
		else
			item['travis_yml'] = false
        end
    
        recent.push(item)
        #break if recent.length > 5
    end
    
    #pp recent
    
    # save to json file
    # another piece of code to generate html
    f = File.new('recent.json', 'w')
    f.write(JSON.generate(recent))
    f.close
end


def get(url, params = {})
    #params ||= {}
    params["User-Agent"] ||= "Code-Maven (see: http://code-maven.com/ )"
    #puts "-> Fetching #{url}"
    #pp params
    fh = open(url, params)
    return fh.read
end

main()
