class Rgbds < Formula
  desc "Rednex GameBoy Development System"
  homepage "https://rgbds.gbdev.io"
  url "https://github.com/gbdev/rgbds/archive/v0.4.2.tar.gz"
  sha256 "2579cbd6cc47bc944038d17ec3af640e2782c67fdffe7093e6083430543c9780"
  license "MIT"
  head "https://github.com/gbdev/rgbds.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "683197419321366aa097980b0c982698fca0082c72ddafc09f0679404c322e9d"
    sha256 cellar: :any, big_sur:       "6c4d8fece0d52778f3d939832bfcb46f3e339248228ed166f7e604339c1b2833"
    sha256 cellar: :any, catalina:      "4ffdbfb56810ee5ab1d54c647fe5a232954b78b024b2ecbcc3ff009f48d38f8e"
    sha256 cellar: :any, mojave:        "a61753b345b81f0378916971fdf7629744556fe6d3c04c85afdec27669641e48"
    sha256 cellar: :any, x86_64_linux:  "99c6f33c7665084770b0bfbb64970309411174dc3a8ddea118e6a93d8c864d69"
  end

  depends_on "bison" => :build
  depends_on "pkg-config" => :build
  depends_on "libpng"

  uses_from_macos "bison" => :build

  def install
    system "make", "install", "PREFIX=#{prefix}", "mandir=#{man}"
  end

  test do
    # https://github.com/rednex/rgbds/blob/HEAD/test/asm/assert-const.asm
    (testpath/"source.asm").write <<~EOS
      SECTION "rgbasm passing asserts", ROM0[0]
        db 0
        assert @
    EOS
    system "#{bin}/rgbasm", "source.asm"
  end
end
