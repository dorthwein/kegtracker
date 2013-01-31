class Api::WidgetsController < ApplicationController
	before_filter :authenticate_user!	
	def filter_tree_widget
		respond_to do |format|  		
			format.json { 
				gatherer = Gatherer.new current_user.entity
				widget_builder = WidgetBuilder.new(current_user, Time.new.beginning_of_day - (86400 * 90), Time.new.end_of_day)

				tree = widget_builder.filter_tree_widget
				#gahterer.asset_activity_fact_criteria



				render json: tree
			}
		end	
	end
end
