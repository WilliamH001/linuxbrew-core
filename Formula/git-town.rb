class GitTown < Formula
  desc "High-level command-line interface for Git"
  homepage "https://www.git-town.com/"
  url "https://github.com/git-town/git-town/archive/v7.5.0.tar.gz"
  sha256 "4f35a2b4d01bea909161722ee1d5d893d5c676e6f3cf9305a864a01c55038be3"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "7dff43547bc7bccf0aa299b64bd238b32750c260f6a549ffe794c3ccc24f7967"
    sha256 cellar: :any_skip_relocation, big_sur:       "87d70a3cdbee842e1395da79b38de127234541c1bdade78a7b20148037af45d5"
    sha256 cellar: :any_skip_relocation, catalina:      "385eb3fecf752f8685c9ed0707ba0d960fe814cb486f5a6c078fdc8bcee89a07"
    sha256 cellar: :any_skip_relocation, mojave:        "279e89fd331b94bbe3f97b51d8a2015d03a72b1efef5934676d4220f69610778"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5b9c177cf5be4d883a67d1e41db72aae80eef3f05d050f2005414f2fc004b4a8"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags",
           "-X github.com/git-town/git-town/src/cmd.version=v#{version} "\
           "-X github.com/git-town/git-town/src/cmd.buildDate=#{Time.new.strftime("%Y/%m/%d")}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/git-town version")

    system "git", "init"
    unless OS.mac?
      system "git", "config", "user.email", "you@example.com"
      system "git", "config", "user.name", "Your Name"
    end
    touch "testing.txt"
    system "git", "add", "testing.txt"
    system "git", "commit", "-m", "Testing!"

    system "#{bin}/git-town", "config"
  end
end
