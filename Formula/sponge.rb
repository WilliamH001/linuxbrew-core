class Sponge < Formula
  desc "Soak up standard input and write to a file"
  homepage "https://joeyh.name/code/moreutils/"
  url "https://git.joeyh.name/index.cgi/moreutils.git/snapshot/moreutils-0.63.tar.gz"
  sha256 "4fc86d56a8a276a0cec71cdabda5ccca50c7a44a2a1ccd888476741d1ce6831d"
  license "GPL-2.0-only"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "5b0e74d146e19640d3075302bdd5ad212bee4971c12b3420f043d61c5a037081"
    sha256 cellar: :any_skip_relocation, big_sur:       "2c0cedfe7ba4f0130001c764671275f4ca2f7c649105fb2433905c9af5fc9912"
    sha256 cellar: :any_skip_relocation, catalina:      "b913bb8811814b0541192ab204784859bc30af5003cf8d2b462722003d2038f9"
    sha256 cellar: :any_skip_relocation, mojave:        "19df51f19f13b1742b5f81bebd1c68cf2bb7d9693c3dae587e171ab57cb7fdca"
    sha256 cellar: :any_skip_relocation, high_sierra:   "c25d99fcacc21592944ed74b6390ce8f81d60dbd03e2122b75a544542ec18cb8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "cabe0c46629b52a060d0ee2ef1a068653887fe00f5d3d42648632d69987036ea"
  end

  conflicts_with "moreutils", because: "both install a `sponge` executable"

  def install
    system "make", "sponge"
    bin.install "sponge"
  end

  test do
    file = testpath/"sponge-test.txt"
    file.write("c\nb\na\n")
    system "sort #{file} | #{bin/"sponge"} #{file}"
    assert_equal "a\nb\nc\n", File.read(file)
  end
end
