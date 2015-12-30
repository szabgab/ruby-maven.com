require 'open-uri'
require 'json'
require 'pp'


def main()
    url = 'https://rubygems.org/api/v1/activity/just_updated.json'
    response = get(url)
    gems = JSON.parse(response)
    #pp gems

	recent = []
	begin
    	f = File.new('recent.json', 'r')
    	recent = JSON.parse(f.read)
    	f.close
	rescue
	end	

	# TODO report if the number of entries added was close to the total number downloaded in the 'recent' request
	# then we need to increase the frequencey of our polling
	
	# TODO maybe change the processing to
	#   step one save all the recent in the "database"
	#   go over all the N recent and where there is no travis.yml check it,  this way if someone adds .travis.yml we'll update our data even without a new release to RubyGems.

	# Apparenty the source_code_uri field cannot be added via the gemspec file yet and one need to add it via a GUI at https://rubygems.org/gems/<gem_name>/edit
	# For historical reason many people put the URL of their GitHub repository in the homepage_uri field.
	# http://guides.rubygems.org/specification-reference/

	# Create your first gem: http://guides.rubygems.org/publishing/
	# Maybe new gems are not in that feed, only in the other feed?


	#pp recent
    
    gems.each do |g|
        #pp g
        #exit

		is_new = true
		recent.each do |r|
			if (r['name'] == g['name'] and Gem::Version.new(g['version']) <= Gem::Version.new(r['version']))
				is_new = false
				break
    		end
		end
		if (not is_new)
			break
		end
		#puts "Adding #{g['name']}  #{g['version']}"

        item = {
            'name' => g['name'],
            'version' => g['version']
        }
        repository_url = g['metadata']['source_code_uri'] || g['homepage_uri']
        if (repository_url == nil or repository_url == '') 
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
