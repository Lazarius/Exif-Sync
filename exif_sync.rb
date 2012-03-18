#! /usr/bin/env ruby

#  Exif Sync
#  Sync two dir based on the unique ID set in the Exif of 
#  each Photo to keep only the selected one from the first dir 
#  in the second dir.
# 
#  Author: Maxime Menant
#  Created on 2012-03-18


require 'rubygems'
require 'fileutils'
require 'mini_exiftool'

##################
orig_dir = ARGV[0]
sync_dir = ARGV[1]

if orig_dir.nil? || sync_dir.nil?
 puts "Use exif_sync dir1 dir2"
 exit
end

def dir_exist?(dir)
  unless Dir.exist?(dir)
    puts "#{dir} doesn't exist"
    return false
  end
  true
end

exit unless dir_exist?(orig_dir)
exit unless dir_exist?(sync_dir)

# Scan original dir for exif ID
orig_exif_ids = []

puts 'Scanning....'
Dir.foreach(orig_dir) do |file|
  next unless file =~ /[.]jpg/i
  exif = MiniExiftool.new File.join(orig_dir, file)
  id = exif.original_documentID
  orig_exif_ids << id unless id.nil?
end
puts "#{orig_exif_ids.count} pictures scanned"

# Sync the new export dir
removed_dir = File.join(sync_dir, 'removed')
Dir.mkdir removed_dir unless Dir.exist? removed_dir

moved_count = 0

puts "Sync start"
Dir.foreach(sync_dir) do |file|
  next unless file =~ /[.]jpg/i
  
  exif = MiniExiftool.new File.join(sync_dir, file)
  if orig_exif_ids.include?(exif.original_documentID)
    print '.'
  else
    print 'R'
    FileUtils.mv(File.join(sync_dir, file), File.join(removed_dir, file))
    moved_count += 1
  end
end

puts ''
puts "Sync done, #{moved_count} files moved to #{removed_dir}"

