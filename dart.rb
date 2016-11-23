require 'formula'

class Dart < Formula
  homepage 'https://www.dartlang.org/'

  version '1.20.1'
  if MacOS.prefer_64_bit?
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.20.1/sdk/dartsdk-macos-x64-release.zip'
    sha256 '7be95b4038d0f63dad006119e79cd49092244e42f5fdfde4c7e7004e44eae9c0'
  else
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.20.1/sdk/dartsdk-macos-ia32-release.zip'
    sha256 '39a4a5f939988b9a1ae62e6f56ba3a40e4f3cd076dcaf68ccd0b40d4a1f84561'
  end

  option 'with-content-shell', 'Download and install content_shell -- headless Dartium for testing'
  option 'with-dartium', 'Download and install Dartium -- Chromium with Dart'

  devel do
    version '1.21.0-dev.9.0'
    if MacOS.prefer_64_bit?
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.21.0-dev.9.0/sdk/dartsdk-macos-x64-release.zip'
      sha256 '95af034ebccdbc47915a663c6af8efe86c1e983ea2b0f03482ce763dc4d694fb'
    else
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.21.0-dev.9.0/sdk/dartsdk-macos-ia32-release.zip'
      sha256 '40f4f232610fa17926d6990acc05a780ec2875f31f2a767c080fc190e85989e3'
    end

    resource 'content_shell' do
      version '1.21.0-dev.9.0'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.21.0-dev.9.0/dartium/content_shell-macos-x64-release.zip'
      sha256 '478d24fbd09e7a04e4b2b8a5550bed26d4dfe234173f4e9de08b5cd1cddab35a'
    end

    resource 'dartium' do
      version '1.21.0-dev.9.0'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.21.0-dev.9.0/dartium/dartium-macos-x64-release.zip'
      sha256 '11331ae01497678c95f55e3d7d812ab6eceec5a0b60e5d62f2608ca22752301f'
    end
  end

  resource 'content_shell' do
    version '1.20.1'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.20.1/dartium/content_shell-macos-x64-release.zip'
    sha256 'a45f7bf0456ed8f4defb10cf5f35a7ed806fa2b3860c99dfd04d87885d28b165'
  end

  resource 'dartium' do
    version '1.20.1'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.20.1/dartium/dartium-macos-x64-release.zip'
    sha256 'c35a4ecda5ff81fb5557a7161350f1fa630d80eb42f8ad94f8a17e1fad6b0fe3'
  end

  def install
    libexec.install Dir['*']
    bin.install_symlink "#{libexec}/bin/dart"
    bin.write_exec_script Dir["#{libexec}/bin/{pub,dart?*}"]

    if build.with? 'dartium'
      dartium_binary = 'Chromium.app/Contents/MacOS/Chromium'
      prefix.install resource('dartium')
      (bin+"dartium").write shim_script dartium_binary
    end

    if build.with? 'content-shell'
      content_shell_binary = 'Content Shell.app/Contents/MacOS/Content Shell'
      prefix.install resource('content_shell')
      (bin+"content_shell").write shim_script content_shell_binary
    end
  end

  def shim_script target
    <<-EOS.undent
      #!/usr/bin/env bash
      exec "#{prefix}/#{target}" "$@"
    EOS
  end

  def caveats; <<-EOS.undent
    Please note the path to the Dart SDK:
      #{opt_libexec}

    --with-dartium:
      To use with IntelliJ, set the Dartium execute home to:
        #{opt_prefix}/Chromium.app
    EOS
  end

  test do
    (testpath/'sample.dart').write <<-EOS.undent
      void main() {
        print(r"test message");
      }
    EOS

    assert_equal "test message\n", shell_output("#{bin}/dart sample.dart")
  end
end
