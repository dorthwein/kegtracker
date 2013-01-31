class Api::ChartsController < ApplicationController
	before_filter :authenticate_user!	
	def filter_tree_widget
		respond_to do |format|  		
			format.json { 
				gatherer = Gatherer.new current_user.entity
				widget_builder = WidgetBuilder.new(current_user, Time.new.beginning_of_day - (86400 * 30), Time.new.end_of_day)

				tree = widget_builder.filter_tree_widget
				#gahterer.asset_activity_fact_criteria

				render json: tree
			}
		end	
	end
	def current_sku_quantities
		respond_to do |format|  
			format.json {

				chart_builder = ChartBuilder.new current_user

				time_start = Time.new.beginning_of_day
				time_end = Time.new.end_of_day

				response = chart_builder.current_sku_quantities(time_start, time_end, params[:filter_data])
				render json: response
#				render json: params[:filter_data]
			}
		end
	end

	def assets_by_network
		respond_to do |format|  
			format.json {
				chart_builder = ChartBuilder.new current_user
				
				time_start = Time.new.beginning_of_day - (86400 * 30)
				time_end = Time.new.end_of_day
				
				# def assets_by_network fact_time_start = Time.new.beginning_of_day, fact_time_end = Time.new.end_of_day, filter = {}, 
				response = chart_builder.assets_by_network(time_start, time_end, params[:filter_data])
				
				render json: response

			}
		end
	end
	def sku_by_network
		respond_to do |format|  
			format.json {
				chart_builder = ChartBuilder.new current_user
				
				time_start = Time.new.beginning_of_day - (86400 * 30)
				time_end = Time.new.end_of_day
				
				# def assets_by_network fact_time_start = Time.new.beginning_of_day, fact_time_end = Time.new.end_of_day, filter = {}, 
				response = chart_builder.sku_by_network(time_start, time_end, params[:filter_data])				
				render json: response
			}
		end
	end
end
