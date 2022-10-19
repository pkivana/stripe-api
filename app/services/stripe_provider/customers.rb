require 'csv'

class StripeProvider::Customers < StripeProvider::Base

  CSV_PATH = 'public/customers.csv'

  attr_accessor :customers

  def initialize
    @customers = []
  end

  def create_csv
    add_list_to_csv
  end

  private

  def add_list_to_csv
    retries = 0
    begin
      customers_list_to_array
      write_csv if customers.any?
    rescue Stripe::RateLimitError => e
      # It is extremely unlikely for users to experience any rate limits with
      # normal usage of the API, even at high volume. Even if something like this
      # happens, trying again should solve the problem. With each retry, the wait
      # time increases so that the error should not recur after a few seconds of waiting.

      retries += 1

      return false  if retries > 3

      sleep(retries)
      retry
    rescue => e
      "Something went wrong, error: #{e}"
    end
  end

  def customers_list_to_array
    customers_list.auto_paging_each do |customer|
      @customers << [customer[:id], customer[:email], customer[:name], customer[:currency]]
    end
  end

  def customers_list
    list = Stripe::Customer.list({ limit: 50, starting_after: starting_after })

    if list.empty?
      list = Stripe::Customer.list({ limit: 50 })
      File.delete(CSV_PATH)
    end

    list
  end

  def write_csv
    csv = CSV.parse(customers.map(&:to_csv).join, headers: headers)

    File.write(CSV_PATH, csv, mode: file_mode)
  end

  def customers_file_exist?
    File.exist?(CSV_PATH)
  end

  def last_customer_id
    CSV.read(CSV_PATH).last[0]
  end

  def starting_after
    customers_file_exist? ? last_customer_id : nil
  end

  def file_mode
    customers_file_exist? ? 'a' : 'w'
  end

  def headers
    customers_file_exist? ? true : %i[ID, Email, Name, currency]
  end
end
