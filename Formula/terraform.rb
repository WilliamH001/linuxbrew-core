class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/v0.14.8.tar.gz"
  sha256 "83429a8601922218b2bc808f1b7f465ef0d5fbfc5cd87d1db8b91f6ca5d31b0b"
  license "MPL-2.0"
  head "https://github.com/hashicorp/terraform.git"

  livecheck do
    url "https://releases.hashicorp.com/terraform/"
    regex(%r{href=.*?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "340fb2e2ab7c4d2b0a2479442570c1132b5ad1c3b6c1c199380ae99bf9161325"
    sha256 cellar: :any_skip_relocation, big_sur:       "881ab2408b4424f678350f376f8b6cf841ade2140e1e6da24014d4c034408ff2"
    sha256 cellar: :any_skip_relocation, catalina:      "d0464dc60a24f5dee679f5776a1b9beb4065bf6152bcd1b5f01d5b5223b0058a"
    sha256 cellar: :any_skip_relocation, mojave:        "254fa578fbc804f0f0e6e85da05b0bfe556ce55b904b23ea5d943c9b16276250"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "192c42f4e72963588edbd894ffa2a17025f7ab0ee511889aed311011638b998e"
  end

  depends_on "go" => :build

  conflicts_with "tfenv", because: "tfenv symlinks terraform binaries"

  def install
    # v0.6.12 - source contains tests which fail if these environment variables are set locally.
    ENV.delete "AWS_ACCESS_KEY"
    ENV.delete "AWS_SECRET_KEY"

    # resolves issues fetching providers while on a VPN that uses /etc/resolv.conf
    # https://github.com/hashicorp/terraform/issues/26532#issuecomment-720570774
    ENV["CGO_ENABLED"] = "1"

    system "go", "build", *std_go_args, "-ldflags", "-s -w"
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<~EOS
      variable "aws_region" {
        default = "us-west-2"
      }

      variable "aws_amis" {
        default = {
          eu-west-1 = "ami-b1cf19c6"
          us-east-1 = "ami-de7ab6b6"
          us-west-1 = "ami-3f75767a"
          us-west-2 = "ami-21f78e11"
        }
      }

      # Specify the provider and access details
      provider "aws" {
        access_key = "this_is_a_fake_access"
        secret_key = "this_is_a_fake_secret"
        region     = var.aws_region
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami           = var.aws_amis[var.aws_region]
        count         = 4
      }
    EOS
    system "#{bin}/terraform", "init"
    system "#{bin}/terraform", "graph"
  end
end
