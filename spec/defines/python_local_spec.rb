require 'spec_helper'

describe 'python::local' do
  let(:facts) do
    {
      :boxen_home                  => '/opt/boxen',
      :boxen_user                  => 'wfarr',
      :macosx_productversion_major => '10.8'
    }
  end

  let(:title) { '/tmp' }

  context 'ensure => present' do
    let(:params) do
      {
        :version => '2.7.8'
      }
    end

    it do
      should contain_python__version('2.7.8')

      should contain_file('/tmp/.pyenv-version').with_ensure('absent')
      should contain_file('/tmp/.python-version').with({
        :ensure  => 'present',
        :content => "2.7.8\n",
        :replace => true
      })
    end
  end

  context 'ensure => absent' do
    let(:params) do
      {
        :ensure => 'absent',
      }
    end

    it do
      should contain_file('/tmp/.pyenv-version').with_ensure('absent')
      should contain_file('/tmp/.python-version').with_ensure('absent')
    end
  end
end
