require "spec_helper"

describe FeedSource do
  it {should respond_to :name}
  it {should respond_to :url}
  it {should respond_to :feeds}
end