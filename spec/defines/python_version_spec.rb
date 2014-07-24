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
          :python_build => "/test/boxen/python-build/bin/python-build",
          :provider   => 'pythonbuild',
          :user       => 'testuser',
        })
      end
    end

    context "when env is default" do
      it do
        should contain_python('2.7.8').with_environment({
          "CC" => "/usr/bin/cc",
          "FROM_HIERA" => "true",
        })
      end
    end

    context "when env is not nil" do
      let(:params) do
        {
          :env => {'SOME_VAR' => "flocka"}
        }
      end

      it do
        should contain_python('2.7.8').with_environment({
          "CC" => "/usr/bin/cc",
          "FROM_HIERA" => "true",
          "SOME_VAR" => "flocka"
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
