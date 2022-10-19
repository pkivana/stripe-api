# STRIPE APP

This is API implemented to create CSV documents of stripe customers.

# SETUP

You need to have all the development dependencies installed:
  - A recent ruby version (`2.7.5` is used)
  - A recent rails version (`6.1.4.1` is used)
  - The `bundler` ruby gem

Extract git repo

Then:

- Run `bundle install` to install all needed gems
- Set stripe secret key `EDITOR=vim rails credentials:edit` (you can pick your editor), stripe api test key you can find [here](https://stripe.com/docs/keys)

If all is fine, you should be able to run all tests with `rspec`.

- Run `StripeProvider::Customers.new.create_csv` to create stripe customers CSV file
- File will be located in Public folder

Check specs for possible scenarios
