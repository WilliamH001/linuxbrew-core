class Hackrf < Formula
  desc "Low cost software radio platform"
  homepage "https://github.com/mossmann/hackrf"
  url "https://github.com/mossmann/hackrf/archive/v2021.03.1.tar.gz"
  sha256 "84a9aef6fe2666744dc1a17ba5adb1d039f8038ffab30e9018dcfae312eab5be"
  license "GPL-2.0-or-later"
  head "https://github.com/mossmann/hackrf.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "233c56f5a051ad74e30f3a18741a39c750b4973e20d580388c11606488e61fc0"
    sha256 cellar: :any,                 big_sur:       "54e9e6ad6edbac05a150b07cab7e23ff6053e2c64c927fdbc63bea7007c7ec9e"
    sha256 cellar: :any,                 catalina:      "903c9d309035f261f336a5c3d456a7947eb14390be917f43f40dbaf2ff0146b6"
    sha256 cellar: :any,                 mojave:        "68d1ffb38ef62af28483d702189ea4019cf81764767d91dd0fa113f39bcbdc0c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "88d1a1b474544b53ec16b80a1b4d7d6414118e0afa503e9b495954ed1eb12ad9"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "libusb"

  def install
    cd "host" do
      args = std_cmake_args
      unless OS.mac?
        args << "-DUDEV_RULES_GROUP=plugdev"
        args << "-DUDEV_RULES_PATH=#{lib}/udev/rules.d"
      end
      system "cmake", ".", *args
      system "make", "install"
    end
  end

  test do
    shell_output("#{bin}/hackrf_transfer", 1)
  end
end
