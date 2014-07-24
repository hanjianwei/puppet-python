require 'spec_helper'

describe 'python::alias' do
  let(:facts) { default_test_facts }

  let(:title) { '2.7.8' }

  let(:default_params) { {
    :to => '2.7',
    :ensure => 'installed'
  } }

  let(:params) { default_params }

  it do
    should contain_python('2.7')
    should contain_file('/opt/pythons/2.7.8').with({
      :ensure => 'symlink',
      :force  => true,
      :target => '/opt/pythons/2.7'
    }).that_requires('Python::Version[2.7]')
  end

  context "ensure => absent" do
    let(:params) { default_params.merge(:ensure => 'absent') }
    it do
      should_not contain_python('2.7')
      should contain_file('/opt/pythons/2.7.8').with_ensure('absent')
    end
  end
end
