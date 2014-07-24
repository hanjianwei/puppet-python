require "spec_helper"

describe "python" do
  let(:facts) { default_test_facts }

  let(:default_params) do
    {
      :provider => "pyenv",
      :prefix   => "/test/boxen",
    }
  end

  let(:params) { default_params }

  it { should contain_class("python::build") }
  it { should contain_file("/opt/pythons") }

  context "provider is pyenv" do
    let(:params) {
      default_params.merge(:provider => "pyenv")
    }

    it { should contain_class("python::pyenv") }
  end

  context "osfamily is Darwin" do
    let(:facts) {
      default_test_facts.merge(:osfamily => "Darwin")
    }

    it { should contain_class("boxen::config") }
    it { should contain_boxen__env_script("python") }

    it do
      should contain_file("/opt/pythons").with({
        :ensure => "directory",
        :owner  => "testuser",
      })
    end
  end

  context "osfamily is not Darwin" do
    let(:facts) {
      default_test_facts.merge(:osfamily => "Linux", :id => "root")
    }

    it { should_not contain_class("boxen::config") }
    it { should_not contain_boxen__env_script("python") }

    it do
      should contain_file("/opt/pythons").with({
        :ensure => "directory",
        :owner  => "root",
      })
    end
  end
end
