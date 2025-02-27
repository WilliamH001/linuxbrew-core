class Libelf < Formula
  desc "ELF object file access library"
  homepage "https://web.archive.org/web/20181111033959/www.mr511.de/software/english.html"
  url "https://dl.bintray.com/homebrew/mirror/libelf-0.8.13.tar.gz" # using this url since original source is offline ( https://github.com/Homebrew/homebrew-core/pull/54887 )
  sha256 "591a9b4ec81c1f2042a97aa60564e0cb79d041c52faa7416acb38bc95bd2c76d"
  license "LGPL-2.0-or-later"
  revision 1

  # The formula uses archive.org for the homepage and a mirrored version of the
  # last available archive. There seems to be some newer development in the
  # ELF Tool Chain project (https://sourceforge.net/p/elftoolchain/wiki/Home/)
  # but they don't create separate libelf releases. Altogether, there's nothing
  # we can currently check for a new version, so we're skipping this until
  # something changes.
  livecheck do
    skip "No version information available to check"
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "bd7a08bb9750a466bfc18473a61df2095b6d106ffb72f4ed4af706c7385b4202"
    sha256 cellar: :any_skip_relocation, big_sur:       "8b69f55ccec2aa1bfa85bef3fe071077fe281e2bc63dc33cc4344a1cc02e1e26"
    sha256 cellar: :any_skip_relocation, catalina:      "b7635245b64cc7d857c92191c40877cba96871d07f4749f620bc96c63cd2635e"
    sha256 cellar: :any_skip_relocation, mojave:        "7cb626407ee7d61546f2493da91ecc63996d6180949b96b84793e075bd130f2d"
    sha256 cellar: :any_skip_relocation, high_sierra:   "e11504a15c64cd7fca3248ca7ed14eead25a5d63d8bbd9a8e00f076c56602295"
    sha256 cellar: :any_skip_relocation, sierra:        "a771e35555810a4910304e3ca5967ea3e4f8cbe45576e5b2dc6b80cd9c1f0f13"
    sha256 cellar: :any_skip_relocation, el_capitan:    "a06b058c7e401942f442f573b63aa2cdd548b45d38b02b7af92393c67093f56e"
    sha256 cellar: :any_skip_relocation, yosemite:      "3b4ea9ab20228d9e912f80a330b6d6d093f9bb65a712208c83cd49bdcc4fc9ea"
    sha256 cellar: :any_skip_relocation, mavericks:     "eded3b774d412e533f37bc6d5dc133859141653ce953a0d4cbf4a950dda633f6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7bf880eee47f3426bf118683c699ef1b533e8a1d2f76908e481c53e6c93bb5eb" # glibc 2.19
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    # Workaround for ancient config files not recognising aarch64 macos.
    am = Formula["automake"]
    am_share = am.opt_share/"automake-#{am.version.major_minor}"
    %w[config.guess config.sub].each do |fn|
      cp am_share/fn, fn
    end

    system "autoreconf", "-fvi"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-compat"
    # Use separate steps; there is a race in the Makefile.
    system "make"
    system "make", "install"
  end

  test do
    elf_content =  "7F454C460101010000000000000000000200030001000000548004083" \
      "4000000000000000000000034002000010000000000000001000000000000000080040" \
      "80080040874000000740000000500000000100000B00431DB43B96980040831D2B20CC" \
      "D8031C040CD8048656C6C6F20776F726C640A"
    File.open(testpath/"elf", "w+b") do |file|
      file.write([elf_content].pack("H*"))
    end

    (testpath/"test.c").write <<~EOS
      #include <gelf.h>
      #include <fcntl.h>
      #include <stdio.h>

      int main(void) {
        GElf_Ehdr ehdr;
        int fd = open("elf", O_RDONLY, 0);
        if (elf_version(EV_CURRENT) == EV_NONE) return 1;
        Elf *e = elf_begin(fd, ELF_C_READ, NULL);
        if (elf_kind(e) != ELF_K_ELF) return 1;
        if (gelf_getehdr(e, &ehdr) == NULL) return 1;
        printf("%d-bit ELF\\n", gelf_getclass(e) == ELFCLASS32 ? 32 : 64);
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-L#{lib}", "-I#{include}/libelf",
                   "-lelf", "-o", "test"
    assert_match "32-bit ELF", shell_output("./test")
  end
end
