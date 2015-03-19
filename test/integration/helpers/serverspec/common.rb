

apt_packages = %w{ apt }
yum_packages = %w{ cpio bash diffutils python python-iniparse pygpgme rpm-python yum-metadata-parser
pyliblzma rpm pyxattr python-urlgrabber yum-plugin-fastestmirror }

describe "hostupgrade" do

  describe "prerequisites" do

    if ['debian', 'ubuntu'].include?(os[:family])
      apt_packages.each do |pkg|
        describe package(pkg) do
          it { should be_installed }
        end
      end
    elsif ['redhat', 'centos', 'fedora'].include?(os[:family])
      yum_packages.each do |pkg|
        describe package(pkg) do
          it { should be_installed }
        end
      end
    end
  end
end
