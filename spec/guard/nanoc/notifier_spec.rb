# encoding: utf-8
require 'spec_helper'
require 'guard/nanoc/notifier'

describe Guard::NanocNotifier do
  subject { Guard::NanocNotifier }

  it 'should format success message' do
    message = subject.guard_message(true, 2, 4, 10.1)
    message.should == "2 compiled, 4 skipped\nin 10.1 seconds."
  end

  it 'should format fail message' do
    message = subject.guard_message(false, 2, 4, 10.1)
    message.should == "Site can't be compiled,\nplease check."
  end

  it 'should select success image' do
    subject.guard_image(true).should == :success
  end

  it 'should select failed image' do
    subject.guard_image(false).should == :failed
  end

  it 'should call Guard::Notifier' do
    ::Guard::Notifier.should_receive(:notify).with(
      "2 compiled, 4 skipped\nin 10.1 seconds.",
      :title => 'Nanoc site',
      :image => :success
    )
    subject.notify(true, 2, 4, 10.1)
  end

end
