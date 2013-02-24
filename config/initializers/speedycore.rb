# config/initializers/spreedly.rb

if Rails.env.development?  
	SpreedlyCore.configure(:api_login => 'ZCqlTGZYtZQesf5Zodny9jtQwj3', :api_secret => 'Pmrm06fqq4pGrgF3a83OFq1oB6boINInoxtV6pC5mvx7fj0P6KUm0iPLDtFoqv4J' )
else Rails.env.production?  
	SpreedlyCore.configure
end
#SPREEDLYCORE_API_LOGIN:     
#SPREEDLYCORE_API_SECRET:    
