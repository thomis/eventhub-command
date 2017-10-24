require "spec_helper"

RSpec.describe 'Helper' do

  it 'trims http url' do
    expect(trim_url('http://host.ch')).to eq('host.ch')
  end

  it 'trims https url' do
    expect(trim_url('https://host.ch')).to eq('host.ch')
  end

  it 'trims url with backslashes' do
    expect(trim_url('https:\\\\host.ch')).to eq('host.ch')
  end

  it 'trims HTTP url' do
    expect(trim_url('HTTP://host.ch')).to eq('host.ch')
  end

  it 'trims HTTPS url' do
    expect(trim_url('HTTPS://host.ch')).to eq('host.ch')
  end

end
