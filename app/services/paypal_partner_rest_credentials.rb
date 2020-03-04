class PaypalPartnerRestCredentials
  API_RETRY_TIMEOUT_IN_SECONDS = 2 # Number of seconds before the API request is retried on failure
  API_MAX_TRIES                = 3 # Number of times the API request will be made including retries

  include HTTParty

  base_uri PAYPAL_REST_ENDPOINT
  headers("Accept" => "application/json",
          "Accept-Language" => "en_US")

  def auth_token
    extract_token(request_for_api_token)
  end

  private
    def request_for_api_token
      tries ||= API_MAX_TRIES

      self.class.post("/v1/oauth2/token",
                      body: {
                        "grant_type" => "client_credentials"
                      },
                      basic_auth: {
                        username: PAYPAL_PARTNER_CLIENT_ID,
                        password: PAYPAL_PARTNER_CLIENT_SECRET
                      })
    rescue *INTERNET_EXCEPTIONS => exception
      if (tries -= 1).zero?
        raise exception
      else
        sleep(API_RETRY_TIMEOUT_IN_SECONDS)
        retry
      end
    end

    def extract_token(response)
      "#{response['token_type']} #{response['access_token']}"
    end
end
