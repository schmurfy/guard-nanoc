# encoding: utf-8
require 'spec_helper'
require 'guard/nanoc/runners/default_nanoc_runner'

describe DefaultNanocRunner do
  subject { DefaultNanocRunner.new }

  before(:each) do
    FileUtils.cd(@fixture_path.join('nanoc_site'))

    @site = mock(:nanoc_site, :compile => true, :items => [])
    Nanoc3::Site.stub!(:new).and_return(@site)
    Nanoc3::CLI::Logger.instance.stub!(:file)

    subject.stub(:puts)
  end

  context '#run' do
    
    it 'should initialize runner' do
      subject.stub(:run).and_return(true)
      DefaultNanocRunner.should_receive(:new).and_return(subject)
      DefaultNanocRunner.run
    end

    it 'should call run instance method' do
      subject.should_receive(:run).and_return(true)
      DefaultNanocRunner.stub!(:new).and_return(subject)
      DefaultNanocRunner.run
    end

  end

  context 'run' do

    it 'should call nanoc compile' do
      @site.should_receive(:compile)
      subject.run
    end

    it 'success should call notifier' do
      @site.should_receive(:items).and_return([mock(:reps, :reps => [
        mock(:rep, :compiled? => true, :raw_paths => {:test1 => 'test/1'}, :to_ary => nil ),
        mock(:rep, :compiled? => false, :raw_paths => {:test2 => 'test/2'}, :to_ary => nil ),
        mock(:rep, :compiled? => false, :raw_paths => {:test3 => 'test/3'}, :to_ary => nil )
      ])])
      Guard::NanocNotifier.should_receive(:notify).with(true, 1, 2, anything())
      subject.run
    end

    it 'should count skipped reps' do
      @site.should_receive(:items).and_return([mock(:reps, :reps => [
        mock(:rep, :compiled? => true, :raw_paths => {:test1 => 'test/1'}, :to_ary => nil ),
        mock(:rep, :compiled? => false, :raw_paths => {:test2 => 'test/2'}, :to_ary => nil ),
        mock(:rep, :compiled? => false, :raw_paths => {:test3 => 'test/3'}, :to_ary => nil )
      ])])
      subject.run
      subject.compiled_reps.should == 1
      subject.skipped_reps.should  == 2
    end

    it 'failure should print error' do
      @site.stub!(:compile).and_return { raise Exception }
      subject.should_receive(:print_error)
      subject.run
    end

    it 'failure should call notifier' do
      subject.stub!(:print_error)
      @site.stub!(:compile).and_return { raise Exception }
      Guard::NanocNotifier.should_receive(:notify).with(false, 0, 0, anything())
      subject.run
    end
    
  end
  
end
