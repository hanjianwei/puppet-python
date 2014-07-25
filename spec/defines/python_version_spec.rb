require 'spec_helper'

describe 'python::version' do
  let(:facts) { default_test_facts }
  let(:title) { '2.7.8' }

  context "ensure => present" do
    context "default params" do
      it do
        should contain_class('python')

        should contain_python('2.7.8').with({
          :ensure     => "installed",
          :python_build => "/test/boxen/pyenv/plugins/python-build/bin/python-build",
          :provider   => 'pythonbuild',
          :user       => 'testuser',
        })
      end
    end
  end

  context "ensure => absent" do
    let(:params) do
      {
        :ensure => 'absent'
      }
    end

    it do
      should contain_python('2.7.8').with_ensure('absent')
    end
  end
end
