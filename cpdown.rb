require 'logger'
require 'copied_files'

# Constants
COPIED = "copied"
LOGFILE = "log"

# Logging
log = Logger.new(LOGFILE, File::WRONLY | File::APPEND)
log.level = Logger::INFO

# CopiedFile list
copied = CopiedFiles.new(COPIED, log)


