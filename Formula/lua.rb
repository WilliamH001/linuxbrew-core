class Lua < Formula
  desc "Powerful, lightweight programming language"
  homepage "https://www.lua.org/"
  url "https://www.lua.org/ftp/lua-5.4.2.tar.gz"
  sha256 "11570d97e9d7303c0a59567ed1ac7c648340cd0db10d5fd594c09223ef2f524f"
  license "MIT"
  revision 1 unless OS.mac?

  livecheck do
    url "https://www.lua.org/ftp/"
    regex(/href=.*?lua[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "7ba9cee9e5c01a0801a19226ba577ec2acf84244f7370c5de0f8ee7942948cd0"
    sha256 cellar: :any,                 big_sur:       "f7e0d6c4b3cd8d3fba1f26dd81d23eb68e1adfcd6f7915732449a8671eedfb1c"
    sha256 cellar: :any,                 catalina:      "7fa53bc358e3fc6ebd2e1bcc326cd13f18141d780d07daadcecb891ebe61aa94"
    sha256 cellar: :any,                 mojave:        "0196098bf8f4f49c78061412237acda0e2e2010f4abc61a7ac085ede71e9b7a3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1f41b53691adf6f37b1099f03ab6f898283611771f65b4b5ff513be0c5b0f7d7"
  end

  uses_from_macos "unzip" => :build

  on_macos do
    # Be sure to build a dylib, or else runtime modules will pull in another static copy of liblua = crashy
    # See: https://github.com/Homebrew/legacy-homebrew/pull/5043
    # ***Update me with each version bump!***
    patch :DATA
  end

  on_linux do
    depends_on "readline"

    # Add shared library for linux
    # Equivalent to the mac patch carried around here ... that will probably never get upstreamed
    # Inspired from http://www.linuxfromscratch.org/blfs/view/cvs/general/lua.html
    patch do
      url "https://gist.githubusercontent.com/dawidd6/fbec1d0179f8b8f7d026ed48c2f177a6/raw/a03a2dc572287314861db3c5f761427c30691c29/lua-5.4.patch"
      sha256 "6549934065eb131a13713dca7fd5143b9d90e3f0654be49294cf56bc4bb5cc0f"
    end
  end

  def install
    # Fix: /usr/bin/ld: lapi.o: relocation R_X86_64_32 against `luaO_nilobject_' can not be used
    # when making a shared object; recompile with -fPIC
    # See http://www.linuxfromscratch.org/blfs/view/cvs/general/lua.html
    ENV.append_to_cflags "-fPIC" unless OS.mac?

    # Substitute formula prefix in `src/Makefile` for install name (dylib ID).
    # Use our CC/CFLAGS to compile.
    inreplace "src/Makefile" do |s|
      s.gsub! "@LUA_PREFIX@", prefix if OS.mac?
      s.remove_make_var! "CC"
      s.change_make_var! "CFLAGS", "#{ENV.cflags} -DLUA_COMPAT_5_3 $(SYSCFLAGS) $(MYCFLAGS)"
      s.change_make_var! "MYLDFLAGS", ENV.ldflags
    end

    # Fix path in the config header
    inreplace "src/luaconf.h", "/usr/local", HOMEBREW_PREFIX

    # We ship our own pkg-config file as Lua no longer provide them upstream.
    arch = OS.mac? ? "macosx" : "linux"
    system "make", arch, "INSTALL_TOP=#{prefix}", "INSTALL_INC=#{include}/lua", "INSTALL_MAN=#{man1}"
    system "make", "install", "INSTALL_TOP=#{prefix}", "INSTALL_INC=#{include}/lua", "INSTALL_MAN=#{man1}"
    (lib/"pkgconfig/lua.pc").write pc_file

    # Fix some software potentially hunting for different pc names.
    bin.install_symlink "lua" => "lua#{version.major_minor}"
    bin.install_symlink "lua" => "lua-#{version.major_minor}"
    bin.install_symlink "luac" => "luac#{version.major_minor}"
    bin.install_symlink "luac" => "luac-#{version.major_minor}"
    (include/"lua#{version.major_minor}").install_symlink Dir[include/"lua/*"]
    lib.install Dir[shared_library("src/liblua", "*")] unless OS.mac?
    lib.install_symlink shared_library("liblua", version.major_minor) => shared_library("liblua#{version.major_minor}")
    (lib/"pkgconfig").install_symlink "lua.pc" => "lua#{version.major_minor}.pc"
    (lib/"pkgconfig").install_symlink "lua.pc" => "lua-#{version.major_minor}.pc"
  end

  def pc_file
    <<~EOS
      V= #{version.major_minor}
      R= #{version}
      prefix=#{HOMEBREW_PREFIX}
      INSTALL_BIN= ${prefix}/bin
      INSTALL_INC= ${prefix}/include/lua
      INSTALL_LIB= ${prefix}/lib
      INSTALL_MAN= ${prefix}/share/man/man1
      INSTALL_LMOD= ${prefix}/share/lua/${V}
      INSTALL_CMOD= ${prefix}/lib/lua/${V}
      exec_prefix=${prefix}
      libdir=${exec_prefix}/lib
      includedir=${prefix}/include/lua

      Name: Lua
      Description: An Extensible Extension Language
      Version: #{version}
      Requires:
      Libs: -L${libdir} -llua -lm #{"-ldl" unless OS.mac?}
      Cflags: -I${includedir}
    EOS
  end

  def caveats
    <<~EOS
      You may also want luarocks:
        brew install luarocks
    EOS
  end

  test do
    assert_match "Homebrew is awesome!", shell_output("#{bin}/lua -e \"print ('Homebrew is awesome!')\"")
  end
end

__END__
diff --git a/Makefile b/Makefile
index 1797df9..2f80d16 100644
--- a/Makefile
+++ b/Makefile
@@ -41,7 +41,7 @@ PLATS= guess aix bsd c89 freebsd generic linux linux-readline macosx mingw posix
 # What to install.
 TO_BIN= lua luac
 TO_INC= lua.h luaconf.h lualib.h lauxlib.h lua.hpp
-TO_LIB= liblua.a
+TO_LIB= liblua.5.4.2.dylib
 TO_MAN= lua.1 luac.1

 # Lua version and release.
@@ -60,6 +60,8 @@ install: dummy
 	cd src && $(INSTALL_DATA) $(TO_INC) $(INSTALL_INC)
 	cd src && $(INSTALL_DATA) $(TO_LIB) $(INSTALL_LIB)
 	cd doc && $(INSTALL_DATA) $(TO_MAN) $(INSTALL_MAN)
+	ln -s -f liblua.5.4.2.dylib $(INSTALL_LIB)/liblua.5.4.dylib
+	ln -s -f liblua.5.4.dylib $(INSTALL_LIB)/liblua.dylib

 uninstall:
 	cd src && cd $(INSTALL_BIN) && $(RM) $(TO_BIN)
diff --git a/src/Makefile b/src/Makefile
index 514593d..90c78b8 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -32,7 +32,7 @@ CMCFLAGS= -Os

 PLATS= guess aix bsd c89 freebsd generic linux linux-readline macosx mingw posix solaris

-LUA_A=	liblua.a
+LUA_A=	liblua.5.4.2.dylib
 CORE_O=	lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o ltable.o ltm.o lundump.o lvm.o lzio.o
 LIB_O=	lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o loadlib.o loslib.o lstrlib.o ltablib.o lutf8lib.o linit.o
 BASE_O= $(CORE_O) $(LIB_O) $(MYOBJS)
@@ -57,11 +57,12 @@ o:	$(ALL_O)
 a:	$(ALL_A)

 $(LUA_A): $(BASE_O)
-	$(AR) $@ $(BASE_O)
-	$(RANLIB) $@
+	$(CC) -dynamiclib -install_name @LUA_PREFIX@/lib/liblua.5.4.dylib \
+		-compatibility_version 5.4 -current_version 5.4.2 \
+		-o liblua.5.4.2.dylib $^

 $(LUA_T): $(LUA_O) $(LUA_A)
-	$(CC) -o $@ $(LDFLAGS) $(LUA_O) $(LUA_A) $(LIBS)
+	$(CC) -fno-common $(MYLDFLAGS) -o $@ $(LUA_O) $(LUA_A) -L. -llua.5.4.2 $(LIBS)

 $(LUAC_T): $(LUAC_O) $(LUA_A)
 	$(CC) -o $@ $(LDFLAGS) $(LUAC_O) $(LUA_A) $(LIBS)
@@ -124,7 +125,7 @@ linux-readline:
 	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_LINUX -DLUA_USE_READLINE" SYSLIBS="-Wl,-E -ldl -lreadline"

 Darwin macos macosx:
-	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX -DLUA_USE_READLINE" SYSLIBS="-lreadline"
+	$(MAKE) $(ALL) SYSCFLAGS="-DLUA_USE_MACOSX -DLUA_USE_READLINE -fno-common" SYSLIBS="-lreadline"

 mingw:
 	$(MAKE) "LUA_A=lua54.dll" "LUA_T=lua.exe" \
