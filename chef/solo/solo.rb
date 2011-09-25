# Configuration file for Chef Solo

# IMPORTANT: The file_cache and cookbooks must be absolute paths.

# Parent directory as an absolute path 
PARENT_DIR = File.expand_path('../..')

# The root of the local or remote location of the cookbooks
file_cache_path PARENT_DIR

# The specific cookbook repositories to use
cookbook_path [File.join(PARENT_DIR, 'site-cookbooks')]

# Log detail
#log_level :debug # :info
