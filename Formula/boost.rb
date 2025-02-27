class Boost < Formula
  desc "Collection of portable C++ source libraries"
  homepage "https://www.boost.org/"
  url "https://dl.bintray.com/boostorg/release/1.75.0/source/boost_1_75_0.tar.bz2"
  mirror "https://dl.bintray.com/homebrew/mirror/boost_1_75_0.tar.bz2"
  sha256 "953db31e016db7bb207f11432bef7df100516eeb746843fa0486a222e3fd49cb"
  license "BSL-1.0"
  revision OS.mac? ? 2 : 3
  head "https://github.com/boostorg/boost.git"

  livecheck do
    url "https://www.boost.org/feed/downloads.rss"
    regex(/>Version v?(\d+(?:\.\d+)+)</i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "a6ca6c43f67270378ae0400e66095c329ebe90a1989a4a9c4606f1b8e72a692f"
    sha256 cellar: :any,                 big_sur:       "be8564844a1e5bb58c26287453617458db6e886f85197c8ce35c21cfa74b1bc0"
    sha256 cellar: :any,                 catalina:      "aef0fade9e8159b572907189bb8dfd828dab94c44e036cdd782c2b3834d218f3"
    sha256 cellar: :any,                 mojave:        "e24d396d90a8db75738cba4543b678c79ef720a96bf2f93688bd2f35fef66d3a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fa60d98f6d96bf69e9a954501f51ffbc3b74c846562b57015b55712b9e6c09f9"
  end

  depends_on "icu4c"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  # Reduce INTERFACE_LINK_LIBRARIES exposure for shared libraries. Remove with the next release.
  patch do
    url "https://github.com/boostorg/boost_install/commit/7b3fc734242eea9af734d6cd8ccb3d8f6b64c5b2.patch?full_index=1"
    sha256 "cd96f5c51fa510fa6cd194eb011c0a6f9beb377fa2e78821133372f76a3be349"
    directory "tools/boost_install"
  end

  # Fix build on 64-bit arm
  patch do
    url "https://github.com/boostorg/build/commit/456be0b7ecca065fbccf380c2f51e0985e608ba0.patch?full_index=1"
    sha256 "e7a78145452fc145ea5d6e5f61e72df7dcab3a6eebb2cade6b4cfae815687f3a"
    directory "tools/build"
  end

  def install
    # Force boost to compile with the desired compiler
    open("user-config.jam", "a") do |file|
      if OS.mac?
        file.write "using darwin : : #{ENV.cxx} ;\n"
      else
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
    end

    # libdir should be set by --prefix but isn't
    icu4c_prefix = Formula["icu4c"].opt_prefix
    bootstrap_args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      --with-icu=#{icu4c_prefix}
    ]

    # Handle libraries that will not be built.
    without_libraries = ["python", "mpi"]

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc

    bootstrap_args << "--without-libraries=#{without_libraries.join(",")}"

    # layout should be synchronized with boost-python and boost-mpi
    args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      -sNO_LZMA=1
      -sNO_ZSTD=1
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    # Fix error: bzlib.h: No such file or directory
    # and /usr/bin/ld: cannot find -lbz2
    args += ["include=#{HOMEBREW_PREFIX}/include", "linkflags=-L#{HOMEBREW_PREFIX}/lib"] unless OS.mac?

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", "headers"
    system "./b2", *args
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <boost/algorithm/string.hpp>
      #include <string>
      #include <vector>
      #include <assert.h>
      using namespace boost::algorithm;
      using namespace std;

      int main()
      {
        string str("a,b");
        vector<string> strVec;
        split(strVec, str, is_any_of(","));
        assert(strVec.size()==2);
        assert(strVec[0]=="a");
        assert(strVec[1]=="b");
        return 0;
      }
    EOS
    if OS.mac?
      system ENV.cxx, "test.cpp", "-std=c++14", "-stdlib=libc++", "-o", "test"
    else
      system ENV.cxx, "test.cpp", "-std=c++14", "-o", "test"
    end
    system "./test"
  end
end
