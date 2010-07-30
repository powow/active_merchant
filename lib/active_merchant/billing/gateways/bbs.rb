module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class BbsGateway < Gateway
      TEST_URL = 'https://epayment-test.bbs.no/Terminal/'
      LIVE_URL = 'https://epayment.bbs.no/Terminal/'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['NO']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.betalingsterminal.no/Netthandel-forside/'
      
      # The name of the gateway
      self.display_name = 'Bankenes Betalingssentral (BBS)'
      
      self.default_currency = 'NOK'
      self.money_format = :cents
      
      SERVICE_TYPES = {
        :netaxept_hosted => "B",
        :merchant_hosted => "M",
        :call_center => "C"
      }
      
      def initialize(options = {})
        requires!(options, :login, :password)
        @options = options
        super
      end
      
      def setup(money, options = {})
        requires!(options, :currency_code, :order_id, :redirect_url)
        post = {}
        add_invoice(post, options)
        add_money(post, money)
        add_currency_code(post, money, options)
        add_redirect_url(post, options)
        add_service_type(post, options)
        add_description(post, options)
        add_force_3dsecure(post, options)
        
        commit('Register', post)
      end
      
      def authorize(transaction_id)
        post = {}
        add_transaction_id(transaction_id)
        commit('Auth', post)
      end
      
      def purchase(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)   
        add_customer_data(post, options)
             
        commit('Sale', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        commit('Capture', money, post)
      end
    
      private                       
      
      def add_customer_data(post, options)
      end

      def add_invoice(post, options)
        post[:orderNumber] = options[:order_id] unless options[:order_id].blank?
      end
      
      def add_money(post, money)
        post[:amount] = amount(money)
      end
      
      def add_currency_code(post, money, options)
        post[:currencyCode] = options[:currency] || currency(money)
      end
      
      def add_redirect_url(post, options)
        post[:redirectUrl] = options[:redirect_url] unless options[:redirect_url].blank?
      end
      
      def add_service_type(post, options)
        post[:serviceType] = service_type(options[:service_type]) unless options[:service_type].blank?
      end
      
      def add_description(post, options)
        post[:description] = options[:description] unless options[:description].blank?
      end
      
      def add_force_3dsecure(post, options)
        unless options[:force_3d_secure].blank?
          post[:force3DSecure] = (!!options[:force_3d_secure])? 1 : 0
        end
      end
      
      def parse(body)
      end     
      
      def commit(action, parameters)
        url = "#{base_url}Process.aspx"
        
        case action
        when "Register"
          url = "#{base_url}Register.aspx"
        when "Auth"
          parameters[:operation] = "AUTH"
        when "Capture"
          parameters[:operation] = "CAPTURE"
        when "Query"
          url = "#{base_url}Query.aspx"
        end
        
        post_data(url, parameters)
      end

      def message_from(response)
      end
      
      def post_data(action, parameters = {})
      end
      
      def service_type(option)
        SERVICE_TYPES[option] || "B"
      end
      
      def base_url
        (test?)? TEST_URL : LIVE_URL
      end
    end
  end
end

