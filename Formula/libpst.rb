class Libpst < Formula
  desc "Utilities for the PST file format"
  homepage "https://www.five-ten-sg.com/libpst/"
  url "https://www.five-ten-sg.com/libpst/packages/libpst-0.6.75.tar.gz"
  sha256 "2f9ddc4727af8e058e07bcedfa108e4555a9519405a47a1fce01e6420dc90c88"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://www.five-ten-sg.com/libpst/packages/"
    regex(/href=.*?libpst[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 2
    sha256 cellar: :any,                 arm64_big_sur: "669e325cb32cbad435d86606d40012aee6d9101b2ffbc6efc9fa101e9bcdf97f"
    sha256 cellar: :any,                 big_sur:       "6f48557a8529e0bc989baaa72788c52289896194e069217bf8fe5cc771207a22"
    sha256 cellar: :any,                 catalina:      "cbf301e72e23ecad7be367063b933bb9ce0ea430f5af413ad44f71b04e4ccae3"
    sha256 cellar: :any,                 mojave:        "b5dff8dd482a5688ce97bc7407ad7a18d620dc264ba1962e155e862ae2973d2b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "80dabad2f545d45a720e235efebe37690488a7070ed3730e1fbd0a632156a1dc"
  end

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "gettext"
  depends_on "libgsf"

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-python
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system bin/"lspst", "-V"
  end
end
