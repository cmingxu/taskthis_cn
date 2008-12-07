def growl(msg, title='Rails Server Message', icon='rb')
   begin
      title.gsub!(/\'/, '`')
      msg.gsub!(/\'/, '`')
      # I like to use this... if you don't have GrowlNotify installed, comment
      # out this line, or have it write to a log, whatever.
      IO::popen( "growlnotify -i #{icon} -s -t '#{title}' -m '#{msg}'" )   
   rescue
      # D'oh!
      puts title
      puts msg
   end
end