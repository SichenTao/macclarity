class Macscope < Formula
  desc "Local-first Mac storage and performance diagnostics"
  homepage "https://github.com/SichenTao/macclarity"
  url "https://github.com/SichenTao/macclarity/archive/refs/tags/v0.1.0.tar.gz"
  version "0.1.0"
  sha256 "REPLACE_AFTER_SIGNED_RELEASE"
  license "Apache-2.0"
  depends_on xcode: ["16.0", :build]
  def install
    system "swift", "build", "-c", "release", "--disable-sandbox", "--product", "macclarity"
    bin.install ".build/release/macclarity"
  end
  test do
    assert_match "macclarity 0.1.0", shell_output("#{bin}/macclarity --version")
  end
end
