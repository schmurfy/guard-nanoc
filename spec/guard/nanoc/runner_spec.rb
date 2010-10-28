# encoding: utf-8
require 'spec_helper'

describe Guard::Nanoc::Runner do
  subject { Guard::Nanoc::Runner }

  describe 'options' do

    describe 'bundler' do

      it 'default should be true if Gemfile exist' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
        subject.new.bundler?.should be_true
      end

      it 'default should be false if Gemfile don\'t exist' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('empty'))
        subject.new.bundler?.should be_false
      end
  
      it 'should be force to false' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
        subject.new(:bundler => false).bundler?.should be_false
      end

    end

    describe 'rubygems' do

      it 'default should be false if Gemfile exist' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
        subject.new.rubygems?.should be_false
      end

      it 'default should be false if Gemfile don\'t exist' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('empty'))
        subject.new.rubygems?.should be_false
      end

      it 'should be set to true if bundler is disabled' do
        subject.new(:bundler => false, :rubygems => true).rubygems?.should be_true
      end

      it 'should not be set to true if bundler is enabled' do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
        subject.new(:bundler => true, :rubygems => true).rubygems?.should be_false
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
        runner = subject.new
        Guard::UI.should_receive(:info)
        runner.should_receive(:system).with(
          "ruby -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        runner.run
      end

      it 'should run without bundler but rubygems' do
        runner = subject.new(:rubygems => true)
        Guard::UI.should_receive(:info)
        runner.should_receive(:system).with(
          "ruby -r rubygems -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        runner.run
      end

    end

    describe 'in bundler folder' do

      before(:each) do
        Dir.stub!(:pwd).and_return(@fixture_path.join('bundler'))
      end

      it 'should run with bundler but not rubygems' do
        runner = subject.new(:bundler => true, :rubygems => false)
        Guard::UI.should_receive(:info)
        runner.should_receive(:system).with(
          "bundle exec ruby -r bundler/setup -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        runner.run
      end

      it 'should run without bundler but rubygems' do
        runner = subject.new(:bundler => false, :rubygems => true)
        Guard::UI.should_receive(:info)
        runner.should_receive(:system).with(
          "ruby -r rubygems -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        runner.run
      end

      it 'should run without bundler and rubygems' do
        runner = subject.new(:bundler => false, :rubygems => false)
        Guard::UI.should_receive(:info)
        runner.should_receive(:system).with(
          "ruby -r #{@default_runner} -e 'DefaultNanocRunner.run'"
        )
        runner.run
      end

    end

  end
end
