# have a custom error handling
# have no "error:"-prefix and all text is red
on_error do |exception|
  $stderr.puts exception.to_s.red
  false # skip GLI's error handling
end

# helper method to trim url
def trim_url(str)
  str.sub(%r{^https?:(//|\\\\)}i, '')
end
