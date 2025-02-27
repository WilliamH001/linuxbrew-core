class Dnsx < Formula
  desc "DNS query and resolution tool"
  homepage "https://github.com/projectdiscovery/dnsx"
  url "https://github.com/projectdiscovery/dnsx/archive/v1.0.1.tar.gz"
  sha256 "cd8111d27333d8f71904befdea7c362babca6698531327b55d8c5c79203c9d75"
  license "MIT"
  head "https://github.com/projectdiscovery/dnsx.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "363d5e89426b1506989364815d019e6d933d0cc64e43ddc978c221af898f98ef"
    sha256 cellar: :any_skip_relocation, big_sur:       "b3b673351d2c889399ac1bcecf1787d5e249cb3a54dc7dafb7835607b9546948"
    sha256 cellar: :any_skip_relocation, catalina:      "f4a4b868cdca5f03c22233f7f9eeb197103311a87372bd10207fd4ae6de1ab09"
    sha256 cellar: :any_skip_relocation, mojave:        "98c11892bb76063840bc27ce8b99c2924e2ed1ed0d20bd155bb6508f97d292a0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "593c2f63315607da6e80e85a952ef6f386a2c3d31d23dfcc120cea3600110b3f"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/dnsx"
  end

  test do
    (testpath/"domains.txt").write "docs.brew.sh"
    expected_output = "docs.brew.sh [homebrew.github.io]"
    assert_equal expected_output,
      shell_output("#{bin}/dnsx -silent -l #{testpath}/domains.txt -cname -resp").strip
  end
end
