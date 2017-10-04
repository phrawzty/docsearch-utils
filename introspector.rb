#!/usr/bin/env ruby

require 'json'
require 'optparse'

# Set runtime options.
options = {}
OptionParser.new do |opts|
    opts.banner = "DocSearch configs go in, delicious insights go out!\nUsage: introspector.rb\n"

    opts.on('--sourcedir DIR', 'Directory where configs are located.') { |v|
        options[:sourcedir] = v
    }
    opts.on('--destjson FILE', 'Dump processed data to JSON.') { |v|
        options[:destjson] = v
    }
    opts.on('--destcsv FILE', 'Dump processed data to CSV.') { |v|
        options[:destcsv] = v
    }

    opts.on('-h', '--help', 'This help.') do
        puts opts
        exit 1
    end
end.parse!

# Require some runtime args.
if not (options[:sourcedir]) then
    puts 'ERROR: Must specify sourcedir. See --help'
    exit 1
end

# Ensure that source dir is accessible.
if File.readable?(options[:sourcedir]) then
    puts 'Reading from: ' + options[:sourcedir]
else
    puts 'ERROR: Could not read configs from ' + options[:sourcedir]
    exit 1
end

# Gather some information.
configs = {}

# Run through the configs.
Dir.glob(options[:sourcedir] + '/*.json') { |configfile|
    puts 'Processing ' + configfile
    configjson = JSON.parse(File.read(configfile))

    # Gather some useful info.
    name = configjson['index_name']

    # Get a URL; this could be a string or, if more complex, a hash.
    url = nil

    # Most sites use start_url; some use XML sitemaps.
    if configjson['start_urls'] then
        url_type = 'start_urls'
    elsif configjson['sitemap_urls'] then
        url_type = 'sitemap_urls'
    end

    if configjson[url_type][0].is_a?(String) then
        url = configjson[url_type][0]
    elsif configjson[url_type][0].is_a?(Hash) then
        url = configjson[url_type][0]['url']
    end
    # This may contain regexes and stuff; maybe fix in the future. :P

    # Add the config.
    configs[name] = {}
    configs[name]['url'] = url
}

# If requested, dump the raw output to a file.
if options[:destjson] then
    puts 'Writing JSON to ' + options[:destjson]
    File.open(options[:destjson], 'w') do |f|
        f.write(JSON.pretty_generate(configs))
    end
end
if options[:destcsv] then
    puts 'Writing CSV to ' + options[:destcsv]
    File.open(options[:destcsv], 'w') do |f|
        configs.each do |k,v|
            f.write(k.to_s + ',' + v['url'].to_s + "\n")
        end
    end
end
