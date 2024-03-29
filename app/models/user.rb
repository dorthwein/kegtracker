class User
  include Mongoid::Document
  include ExtendMongoid
    
  field :record_status, type: Integer, default: 1

#  before_save :ensure_authentication_token
	# Check User Permission		
#	def permission?(permission_id)
#		return !!self.authorizations.find_by_permission_id(permission_id)
#	end
#	def menu?(permission_type_id)		
#		return self.authorizations.joins(:permission => :permission_type).where('permission_types.id' => permission_type_id).length  != 0
#	end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable


    devise :database_authenticatable, # :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :token_authenticatable


	belongs_to :entity, :inverse_of => 'Entity'
  field :entity_description, type: String


	# User Details
	field :first_name, :type => String
	field :last_name, :type => String	
	field :cell_phone, :type => String	
	field :office_phone, :type => String		

=begin	# User Address
	field :name, type: String
	field :street, type: String
	field :city, type: String
	field :state, type: String
	field :zip, type: String
=end	
	  
# 0 Denied = Nothing 
# 1 User = View
# 2 Power User = Create & View
# 3 Admin = Create, View, Edit, Destroy
  field :operation, :type => Integer, default: 0
  field :account, :type => Integer, default: 0
  field :financial, :type => Integer, default: 0

  field :operation_description, type: String
  field :account_description, type: String
  field :financial_description, type: String

  
	# Scanner Permissions - 0 => No, 1 => View
	field :scanner_delivery_pickup, :type => Integer, :default => 0	
	field :scanner_add, :type => Integer, :default => 0	
	field :scanner_fill, :type => Integer, :default => 0	
	field :scanner_move, :type => Integer, :default => 0		

	# Production Permissions 

	# Maintenance Permissions - 0 => No Permissions, 1 => View, 2 => Admin
	field :user_maintenance, :type => Integer, :default => 0	
	field :location_maintenance, :type => Integer, :default => 0	
	field :product_maintenance, :type => Integer, :default => 0	
# 	field :production_maintenance, :type => Integer, :default => 0	
# 	field :network_maintenance, :type => Integer, :default => 0		
	field :barcode_maker_maintenance, :type => Integer, :default => 0

	field :system_admin, :type => Integer, :default => 0
	# embeds_many :authorizations	

  ## Database authenticatable
  field :email, :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
	field :authentication_token, :type => String
  devise :token_authenticatable

  before_save :sync_descriptions  
  def sync_descriptions    
    self.email.downcase! if self.email
    self.entity_description = self.entity.description
    self.ensure_authentication_token
    
    self.operation_description = User.get_permission_description(self.operation)
    self.account_description = User.get_permission_description(self.account)
    self.financial_description = User.get_permission_description(self.financial)
  end
  def self.get_permission_options
    permission_options = [ 
      {:_id => 0, :description => 'Denied'},
      {:_id => 1, :description => 'User'},
      {:_id => 2, :description => 'Power User'},
      {:_id => 3, :description => 'Admin'},      
    ]
    return permission_options
  end
  def self.get_permission_description i
    case i.to_i
    when 0
      return 'Denied' 
    when 1
      return 'User'
    when 2
      return 'Power User'
    when 3
      return 'Admin'
    end
  end   

  def scanner_data
      reponse = {}
      permissions = self.scan_permissions

      response[:toggle_options] = {}
      response[:handle_codes_auto_mode_on] = []
      response[:handle_codes_auto_mode_off] = []

      response[:networks] = []
      response[:locations] = []
      response[:products] = []

      response[:handle_codes_auto_mode_off] = []
      response[:handle_codes_auto_mode_off] = []
      
      if permissions.scanner_delivery_pickup == 1
        response[:handle_codes_auto_mode_on].push({:html => 'Move/Deliver/Pickup', :value => 5})

        response[:handle_codes_auto_mode_on].push({:html => 'Deliver', :value => 1})
        response[:handle_codes_auto_mode_on].push({:html => 'Pickup', :value => 2})
        response[:handle_codes_auto_mode_off].push({:html => 'Move', :value => 5})
      end
      if permissions.scanner_fill == 1            
        response[:handle_codes_auto_mode_on].push({:html => 'Fill', :value => 4})
        response[:handle_codes_auto_mode_off].push({:html => 'Fill', :value => 4})            
      end
      
      if permissions.scanner_add == 1        
        response[:toggle_options][:asset_type] = 1
        response[:handle_codes_auto_mode_off].push({:html => 'Add', :value => 4})            
      end
      networks = current_user.entity.visible_networks
      response[:networks] = networks.map{|x| {:html => x.description, :value => x._id}}      

  end


end
