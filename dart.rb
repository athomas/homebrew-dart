require 'formula'

class Dart < Formula
  homepage 'https://www.dartlang.org/'

  version '1.11.0'
  if MacOS.prefer_64_bit?
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.0/sdk/dartsdk-macos-x64-release.zip'
    sha256 '9e1571a236895389c72a151677b9dfe5a0dca9728402224a63ca78312e1a37f3'
  else
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.0/sdk/dartsdk-macos-ia32-release.zip'
    sha256 'a361d8287f05c37563a562594e86e97d0ad218c622ac5f3500a1a05795089849'
  end

  option 'with-content-shell', 'Download and install content_shell -- headless Dartium for testing'
  option 'with-dartium', 'Download and install Dartium -- Chromium with Dart'

  devel do
    version '1.11.0'
    if MacOS.prefer_64_bit?
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.11.0/sdk/dartsdk-macos-x64-release.zip'
      sha256 '9e1571a236895389c72a151677b9dfe5a0dca9728402224a63ca78312e1a37f3'
    else
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.11.0/sdk/dartsdk-macos-ia32-release.zip'
      sha256 'a361d8287f05c37563a562594e86e97d0ad218c622ac5f3500a1a05795089849'
    end

    resource 'content_shell' do
      version '1.11.0'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.11.0/dartium/content_shell-macos-ia32-release.zip'
      sha256 'ed7e687ce6eb717d195d0c5013f1efe15f9e384fc080fee525eaebbc9e1e6eb9'
    end

    resource 'dartium' do
      version '1.11.0'
      url 'https://storage.googleapis.com/dart-archive/channels/dev/release/1.11.0/dartium/dartium-macos-ia32-release.zip'
      sha256 '59d11a84e096c7959756394737e4370cbe5a483d5b7169cde7b8199b12a07098'
    end
  end

  resource 'content_shell' do
    version '1.11.0'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.0/dartium/content_shell-macos-ia32-release.zip'
    sha256 'ed7e687ce6eb717d195d0c5013f1efe15f9e384fc080fee525eaebbc9e1e6eb9'
  end

  resource 'dartium' do
    version '1.11.0'
    url 'https://storage.googleapis.com/dart-archive/channels/stable/release/1.11.0/dartium/dartium-macos-ia32-release.zip'
    sha256 '59d11a84e096c7959756394737e4370cbe5a483d5b7169cde7b8199b12a07098'
  end

  def install
    libexec.install Dir['*']
    bin.install_symlink "#{libexec}/bin/dart"
    bin.write_exec_script Dir["#{libexec}/bin/{pub,docgen,dart?*}"]

    if build.with? 'content-shell'
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
      #!/bin/bash
      exec "#{prefix}/#{target}" "$@"
    EOS
  end

  def caveats; <<-EOS.undent
    Please note the path to the Dart SDK:
      #{opt_libexec}

    --with-dartium:
      To use with IntelliJ, set the Dartium execute home to:
        #{prefix}/Chromium.app
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
