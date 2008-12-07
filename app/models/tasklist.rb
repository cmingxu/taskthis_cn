class Tasklist < ActiveRecord::Base

	has_many :taskitems, :order=>'position, updated_on', :dependent => :destroy
	belongs_to :user
	acts_as_list :scope=>:user

	validates_presence_of :title

	before_save :create_html
	before_save :create_name

	def complete?
	   taskitems.each do |taskitem| 
	      return false if not taskitem.complete?
	   end
	   true
	end

	def percent_complete
	   sql=<<-EOF
	   select 
	      com.cnt as complete,
	      incom.cnt as incomplete 
	   from 
	      ( 
	         select 
	            count(id) as cnt
	         from 
	            taskitems 
	         where 
	            tasklist_id = #{id} 
	         and
	            complete=1
	      ) as com, 
	      (
	         select 
	            count(id) as cnt
	         from 
	            taskitems 
	         where 
	            tasklist_id = #{id} 
	         and 
	            complete=0
	      ) as incom
	      EOF
	   
	   counts = ActiveRecord::Base.connection.select_one(sql)
	   	   
	   complete = counts['complete'].to_f
	   incomplete = counts['incomplete'].to_f
	   total = complete + incomplete
	   if total > 0 # don't wanna divide by 0
	      # yes, I realize I didn't need to incomplete count to get the percentage
	      ((complete / total) * 100).to_i
	   else
	      0
      end
	end

private

	def create_html
		self.description_html = RedCloth.new( self.description, [:filter_html] ).to_html  unless self.description.nil?
	end

	def create_name
		self.name = Format::sanitize_name( self.title ) if self.name.nil?
	end

end
