# encoding: utf-8
require 'spec_helper'

describe Guard::Nanoc::Runner do
  subject { Guard::Nanoc::Runner }

  after(:each) do
    subject.class_eval do
      @bundler  = nil
      @rubygems = nil
    end
  end

  describe 'options' do

    describe 'bundler' do

      it 'should set bundler to true by default if Gemfile is present' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
        subject.bundler?.should be_true
      end

      it 'should set bundler to false by default if Gemfile is not present' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('empty'))
        subject.bundler?.should be_false
      end

      it 'should use bundler option first' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
        subject.bundler?.should be_true
        subject.set_bundler(:bundler => false)
        subject.bundler?.should be_false
      end

    end

    describe 'rubygems' do

      it 'should set rubygems to false by default' do
        subject.rubygems?.should be_false
      end

      it 'should set rubygems' do
        subject.stub!(:bundler?).and_return(false)
        subject.rubygems?.should be_false
        subject.set_rubygems(:rubygems => true)
        subject.rubygems?.should be_true
      end

      it 'should set rubygems to false if bundler is set to true' do
        subject.stub!(:bundler?).and_return(true)
        subject.rubygems?.should be_false
        subject.set_rubygems(:rubygems => true)
        subject.rubygems?.should be_false
      end

    end
  end

  describe 'run' do

    before(:each) do
      @default_runner = File.expand_path('../../../../lib/guard/nanoc/runners/default_nanoc_runner.rb', __FILE__)
    end

    describe 'in empty folder' do

      before(:each) do
        Dir.stub!(:pwd).and_return(@fixture_path.join('empty'))
      end

      it 'should run without bundler and rubygems' do
        Guard::UI.should_receive(:info)
        subject.should_receive(:system).with(
          "ruby -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        subject.run
      end

      it 'should run without bundler and rubygems' do
        subject.set_rubygems(:rubygems => true)
        Guard::UI.should_receive(:info)
        subject.should_receive(:system).with(
          "ruby -r rubygems -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        subject.run
      end

    end

    describe 'in bundler folder' do

      before(:each) do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
      end

      it 'should run with bundler' do
        Guard::UI.should_receive(:info)
        subject.should_receive(:system).with(
          "bundle exec ruby -r bundler/setup -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        subject.run
      end

    end

  end
end
