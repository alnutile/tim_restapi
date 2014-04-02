## requires
require 'sinatra'
require 'json'
require 'time'
require 'pp'

### datamapper requires
require 'data_mapper'
require 'dm-types'
require 'dm-timestamps'
require 'dm-validations'

## model
### helper modules
#### StandardProperties
module StandardProperties
  def self.included(other)
    other.class_eval do
      property :id, other::Serial
      # property :created_at, DateTime
      # property :updated_at, DateTime
    end
  end
end

#### Validations
module Validations
  def valid_id?(id)
    id && id.to_s =~ /^\d+$/
  end
end

### matter
class Matter
  include DataMapper::Resource
  include StandardProperties
  extend Validations

  property :name, String, :required => true
  property :description, String
end

## set up db
env = ENV["RACK_ENV"]
puts "RACK_ENV: #{env}"
if env.to_s.strip == ""
  abort "Must define RACK_ENV (used for db name)"
end

case env
  when "test"
    DataMapper.setup(:default, "sqlite3::memory:")
  else
    DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

## create schema if necessary
DataMapper.auto_upgrade!

## logger
def logger
  @logger ||= Logger.new(STDOUT)
end

## matterResource application
class MatterResource < Sinatra::Base
  set :methodoverride, true

  ## helpers

  def self.put_or_post(*a, &b)
    put *a, &b
    post *a, &b
  end

  helpers do
    def json_status(code, reason)
      status code
      {
          :status => code,
          :reason => reason
      }.to_json
    end

    def accept_params(params, *fields)
      h = { }
      fields.each do |name|
        h[name] = params[name] if params[name]
      end
      h
    end
  end

  ## GET /matter - return all matters
  get "/matters/?", :provides => :json do
    content_type :json

    if matters = Matter.all
      matters.to_json
    else
      json_status 404, "Not found"
    end
  end

  ## GET /matters/:id - return matter with specified id
  get "/matters/:id", :provides => :json do
    content_type :json

    # check that :id param is an integer
    if Matter.valid_id?(params[:id])
      if matter = Matter.first(:id => params[:id].to_i)
        matter.to_json
      else
        json_status 404, "Not found"
      end
    else
      # TODO: find better error for this (id not an integer)
      json_status 404, "Not found"
    end
  end

  ## POST /matters/ - create new matter
  post "/matters/?", :provides => :json do
    content_type :json

    new_params = accept_params(params, :name, :description)
    matter = Matter.new(new_params)
    if matter.save
      headers["Location"] = "/matters/#{matter.id}"
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.5
      status 201 # Created
      matter.to_json
    else
      json_status 400, matter.errors.to_hash
    end
  end

  ## PUT /matters/:id/:status - change a matter's status
  put_or_post "/matters/:id/status/:status", :provides => :json do
    content_type :json

    if matter.valid_id?(params[:id])
      if matter = Matter.first(:id => params[:id].to_i)
        matter.status = params[:status]
        if matter.save
          matter.to_json
        else
          json_status 400, matter.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## PUT /matters/:id - change or create a matter
  put "/matters/:id", :provides => :json do
    content_type :json

    new_params = accept_params(params, :name, :status)

    if matter.valid_id?(params[:id])
      if matter = Matter.first_or_create(:id => params[:id].to_i)
        matter.attributes = matter.attributes.merge(new_params)
        if matter.save
          matter.to_json
        else
          json_status 400, matter.errors.to_hash
        end
      else
        json_status 404, "Not found"
      end
    else
      json_status 404, "Not found"
    end
  end

  ## DELETE /matters/:id - delete a specific matter
  delete "/matters/:id/?", :provides => :json do
    content_type :json

    if matter = Matter.first(:id => params[:id].to_i)
      matter.destroy!
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.7
      status 204 # No content
    else
      # http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9.1.2
      # Note: section 9.1.2 states:
      #   Methods can also have the property of "idempotence" in that
      #   (aside from error or expiration issues) the side-effects of
      #   N > 0 identical requests is the same as for a single
      #   request.
      # i.e that the /side-effects/ are idempotent, not that the
      # result of the /request/ is idempotent, so I think it's correct
      # to return a 404 here.
      json_status 404, "Not found"
    end
  end

  ## misc handlers: error, not_found, etc.
  get "*" do
    status 404
  end

  put_or_post "*" do
    status 404
  end

  delete "*" do
    status 404
  end

  not_found do
    json_status 404, "Not found"
  end

  error do
    json_status 500, env['sinatra.error'].message
  end

end
