require 'spec_helper'

describe 'python::virtualenv' do
  let(:facts) { default_test_facts }
  let(:title) { 'test@2.7.8' }

  context "ensure => present" do
    let(:params) do
      {
        :from    => '2.7.8',
        :options => '--system-site-packages'
      }
    end

    it do
      should contain_class('python')

      should contain_exec('python_virtualenv_test@2.7.8').that_requires('Python::Version[2.7.8]')
    end
  end
end
