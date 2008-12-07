class Taskitem < ActiveRecord::Base

	belongs_to :tasklist
	belongs_to :user

	acts_as_list :scope=>'tasklist_id = #{tasklist_id} AND complete = 0'

	before_save :create_html
	
	def toggle_complete
	   transaction do 
	      toggle! :complete

	      if complete?
	         remove_from_list
	         update_attribute :position, nil
	      else
	         assume_bottom_position
	      end
	   end
	end
	
private

	def create_html
		self.notes_html = RedCloth.new( self.notes, [:filter_html] ).to_html  unless self.notes.nil?	

	#	if m = BADGE_PATTERN.match( self.name )
	#	   self.name = "%(badge)#{m[1]}% #{m[2]}"
	#	end
	end

   
end
