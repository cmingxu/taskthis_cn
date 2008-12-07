module AccountHelper


   def pref_check_box( key, label )
      prefs = session[:user_prefs]
      html = ""
      if prefs[key]
         html = %!<input type="checkbox" id="prefs_#{key}" name="prefs[#{key}]" checked value="1"/>!
      else
         html = %!<input type="checkbox" id="prefs_#{key}" name="prefs[#{key}]" value="1"/>!      
      end
      html += %!<input type="hidden" name="prefs[#{key}]" value="0"/>!
      html += %!<label for="prefs_#{key}">#{label}</label>!
   end

end
