class Tfsec < Formula
  desc "Static analysis powered security scanner for your terraform code"
  homepage "https://github.com/tfsec/tfsec"
  url "https://github.com/tfsec/tfsec/archive/v0.39.10.tar.gz"
  sha256 "a8da522156d1d644687e277672b8a675ea35a66a4689092cd45b85bb6ac0b21f"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b0cb687a6d2890cd7a1577a7c15ee3dffc2abc3cf7cc15409c8f2f7e87edd473"
    sha256 cellar: :any_skip_relocation, big_sur:       "73b851857de529b82ca69977aa1da551efd7d3e2315b69d30b658e64feb8d8af"
    sha256 cellar: :any_skip_relocation, catalina:      "f594d25a6707827180474b439f3b598ae7c28d19228720ae76fcbe5119e41761"
    sha256 cellar: :any_skip_relocation, mojave:        "920bdb6a1fa7fbb910bcd8a8f1a4967a7ee6ef5a5cb86c477db74012b355d499"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c6b807f89bf9edd1e163da739a380f5f116b047e8e7dda14689e93e2571c2a81"
  end

  depends_on "go" => :build

  def install
    system "scripts/install.sh", "v#{version}"
    bin.install "tfsec"
  end

  test do
    (testpath/"good/brew-validate.tf").write <<~EOS
      resource "aws_alb_listener" "my-alb-listener" {
        port     = "443"
        protocol = "HTTPS"
      }
    EOS
    (testpath/"bad/brew-validate.tf").write <<~EOS
      }
    EOS

    good_output = shell_output("#{bin}/tfsec #{testpath}/good")
    assert_match "No problems detected!", good_output
    assert_no_match(/WARNING/, good_output)
    bad_output = shell_output("#{bin}/tfsec #{testpath}/bad 2>&1")
    assert_match "WARNING", bad_output
  end
end
