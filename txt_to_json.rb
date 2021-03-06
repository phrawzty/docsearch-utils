#!/usr/bin/env ruby

require 'json'
require 'optparse'

# Set runtime options.
options = {}
OptionParser.new do |opts|
    opts.banner = "DocSearch \"private\" configs (.txt) go in, JSON go out!\nUsage: txt_to_json.rb <dir>\n"

    opts.on('--sourcedir DIR', 'Directory where .txt files are located.') do |v|
        options[:sourcedir] = v
    end
    opts.on('--destdir DIR', 'Direcotry where .json will end up (same as sourcedir by default).') do |v|
        options[:destdir] = v
    end
    opts.on('--force', 'Overwrite target JSON (danger!)') do
        options[:force] = true
    end

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

# Set output dir to source dir unless otherwise specified.
if not (options[:destdir]) then
    options[:destdir] = options[:sourcedir]
end

# Ensure dirs are r/w as necessary.
if File.readable?(options[:sourcedir]) then
    puts 'Reading from ' + options[:sourcedir]
else
    puts 'Cannot read from ' + options[:sourcedir]
    exit 1
end

if File.writable?(options[:destdir]) then
    puts 'Writing to ' + options[:destdir]
else
    puts 'Cannot write to ' + options[:destdir]
    exit 1
end

processed = 0
skipped = 0

Dir.glob(options[:sourcedir] + '/*.txt') do |txtfile|
    # Parse the contents; in this case, zero or more email addresses.
    emails = []
    File.readlines(txtfile).each do |x|
        # sometimes there are commas
        x.delete! ','
        # remove newlines, etc
        emails.push(x.strip)
    end

    # Generate a default name based on the filename
    name = File.basename(txtfile, File.extname(txtfile))

    # Build the object that will become JSON
    obj = {}
    obj['name'] = name
    obj['url'] = ''
    obj['emails'] = emails
    obj['categories'] = []

    # Make JSON file from object
    jsonfile = options[:destdir] + '/' + name + '.json'

    if not File.exist?(jsonfile) or options[:force] then
        File.open(jsonfile, 'w') do |f|
            f.puts JSON.pretty_generate(obj)
        end
        puts 'Processed ' + txtfile
        processed += 1
    else
        puts 'Skipped ' + txtfile
        skipped += 1
    end
end

puts 'Total processed: ' + processed.to_s
puts 'Total skipped: ' + skipped.to_s

exit 0
