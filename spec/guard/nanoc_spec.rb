# encoding: utf-8
require 'spec_helper'

describe Guard::Nanoc do
  subject { Guard::Nanoc }

  before(:each) do
    @runner = Guard::Nanoc::Runner.new
    @runner.stub!(:run).and_return(true)
    Guard::Nanoc::Runner.stub!(:new).and_return(@runner)
  end

  context 'initialization' do
    
    it 'should initialize runner' do
      Guard::Nanoc::Runner.should_receive(:new).with({:test => true}).and_return(@runner)
      subject.new([], :test => true)
    end

  end

  context 'start' do

    it 'should return true' do
      subject.new.start.should be_true
    end

  end

  context 'stop' do

    it 'should return true' do
      subject.new.stop.should be_true
    end

  end

  context 'reload' do

    it 'should return true' do
      subject.new.reload.should be_true
    end

  end

  context 'run_all' do

    it 'should call runner' do
      @runner.should_receive(:run).and_return(true)
      guard = subject.new
      guard.run_on_change(['path/file.txt']).should be_true
    end

  end

  context 'run_on_change' do

    it 'should call runner' do
      @runner.should_receive(:run).and_return(true)
      guard = subject.new
      guard.run_on_change(['path/file.txt']).should be_true
    end

  end
  
end
