require 'spec_helper'

describe Source do
  it { should respond_to :name}
  it "should be a Mongoid Document" do
    Source.ancestors.include?(Mongoid::Document).should be true
  end

  it "should include SourceLogger" do
    Source.ancestors.include?(SourceLogger).should be true
  end
end