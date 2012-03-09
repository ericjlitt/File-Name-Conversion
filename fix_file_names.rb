#!/usr/bin/env ruby
require 'find'
require 'fileutils'

if FileTest.exists?("results.txt")
  File.delete("results.txt")
end

@f = File.open('results.txt', 'a')

class String
  def clean_special_characters
    # Remove special characters
    self.gsub(/[*:?<>"]/,"_")
    # Remove trailing (and leading) spaces
    self.strip()
  end
  
  def rename_if_special_characters
    old_path = self
    new_path = self.clean_special_characters
    
    # If there are no special characters to clean, just return the original
    #   string to be safe
    if old_path != new_path
      return new_path
    else
      return old_path
    end
  end
end


def strip_special_characters_from_filenames( start_dir )
  # On every folder, subfolder, and file in start_dir, perform the following
  Find.find( start_dir ) do |path|
    # Get just the last part of the result (the file or folder name)
    old_file_name = File.basename(path)
    # Get everything but the file or folder name
    old_path = File.dirname(path)
    
    # if it's a file, perform the rest
    if FileTest.file?( path )
      # compute new, clean text for file name
      new_file_name = old_file_name.rename_if_special_characters
      new_file_path = "#{old_path}/#{new_file_name}"
      
      # if characters were stripped, we need to rename and record it in the output file
      if old_file_name != new_file_name
        if FileTest.file?( new_file_path )
          @f << "file|#{path}|#{new_file_path}|Error: trying to change #{path} into #{new_file_path} but new file name already exists!\n"
        else 
          @f << "file|#{path}|#{new_file_path}\n"
          File.rename(path, new_file_path)
        end
      end
    end
  end
end

def strip_special_characters_from_dirnames( start_dir )
  # On every folder, subfolder, and file in start_dir, perform the following
  Find.find( start_dir ) do |path|
    if FileTest.directory?( path )
      # compute new, clean text for folder name
      new_path = path.rename_if_special_characters
      
      # if characters were stripped, we need to rename and record it in the output file
      if path != new_path
        if FileTest.directory?( new_path )
          @f << "dir|#{path}|#{new_path}|Error: trying to change #{path} into #{new_path} but new directory name already exists!\n"
        else 
          @f << "dir|#{path}|#{new_path}\n"
          File.rename(path, new_path)
        end
      else
        # if it's no longer a directory, chances are a higher level directory was renamed. if it's a file, it's none of this method's business
        if !FileTest.directory?( new_path ) && !FileTest.file?( path ) && path != "./"
          @f << "dir|#{path}|#{new_path}|Error: #{path} no longer exists! Parent directory was probably renamed. Run this program again.\n"
        end
      end
    end
  end
end


@f << "Type|OldName|NewName|Notes\n"
#puts "Files..."
strip_special_characters_from_filenames("./")

#puts "Directories..."
strip_special_characters_from_dirnames("./")

