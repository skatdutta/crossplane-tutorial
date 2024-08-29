#!/bin/sh

# This script installs the Nix package manager on your system by
# downloading a binary distribution and running its installer script
# (which in turn creates and populates /nix).

{ # Prevent execution if this script was only partially downloaded
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

umask 0022

tmpDir="$(mktemp -d -t nix-binary-tarball-unpack.XXXXXXXXXX || \
          oops "Can't create temporary directory for downloading the Nix binary tarball")"
cleanup() {
    rm -rf "$tmpDir"
}
trap cleanup EXIT INT QUIT TERM

require_util() {
    command -v "$1" > /dev/null 2>&1 ||
        oops "you do not have '$1' installed, which I need to $2"
}

case "$(uname -s).$(uname -m)" in
    Linux.x86_64)
        hash=0164b000880d3d0aa9b49d6cf73e97015153089b45676ce8a0f801999c88cc11
        path=h9732hjmfxzs497d2p9b533vdp1zq34f/nix-2.24.4-x86_64-linux.tar.xz
        system=x86_64-linux
        ;;
    Linux.i?86)
        hash=eff8bf34996ea17d1b38406dff951e984f557ba60e01e72dec4012ded72fdbe3
        path=97bqzgwvhr9i6wwf4l59v0s9yk4wgjip/nix-2.24.4-i686-linux.tar.xz
        system=i686-linux
        ;;
    Linux.aarch64)
        hash=8832cc2b96ca3ce1d6d2bb4ac3c20c9fccb2e99f98dfcf5f9da48e33a3aac594
        path=mfjwivndbz51d29vdg34xfp2slapy3kg/nix-2.24.4-aarch64-linux.tar.xz
        system=aarch64-linux
        ;;
    Linux.armv6l)
        hash=8ea48fd280c22850baa15f98cec9dd62d24ac7f83fbea74600733093f1a05c63
        path=wppnqyqpfw57cy8fg7zcz0h375h5vqim/nix-2.24.4-armv6l-linux.tar.xz
        system=armv6l-linux
        ;;
    Linux.armv7l)
        hash=2fa01403223a8e71653b8601e6cdb89620358938902561967a13367f80f18c7b
        path=2ri0pl05mbk0i34x3jkj84fi9hrl2i4b/nix-2.24.4-armv7l-linux.tar.xz
        system=armv7l-linux
        ;;
    Linux.riscv64)
        hash=3ee3654a62063d47c12a75d81eb9b354f388cb7c8a26d1da2f239812b87f6aee
        path=4aqcanl3cp9bjrvcjwn1ff58hys617mk/nix-2.24.4-riscv64-linux.tar.xz
        system=riscv64-linux
        ;;
    Darwin.x86_64)
        hash=0717aba10e561040458172bbdfa47657f8df786acd370a37ac6e7a812b8d21e6
        path=7s882nn1dznglc1c3raji50kzgj0mqhh/nix-2.24.4-x86_64-darwin.tar.xz
        system=x86_64-darwin
        ;;
    Darwin.arm64|Darwin.aarch64)
        hash=eb0af0c8c2d93ee11deaa43f1da6c1c8dc54da8de2311cf64827ef119857e94e
        path=qzl0cbn134zgq3vqwzdzvs9sx8ncsva9/nix-2.24.4-aarch64-darwin.tar.xz
        system=aarch64-darwin
        ;;
    *) oops "sorry, there is no binary distribution of Nix for your platform";;
esac

# Use this command-line option to fetch the tarballs using nar-serve or Cachix
if [ "${1:-}" = "--tarball-url-prefix" ]; then
    if [ -z "${2:-}" ]; then
        oops "missing argument for --tarball-url-prefix"
    fi
    url=${2}/${path}
    shift 2
else
    url=https://releases.nixos.org/nix/nix-2.24.4/nix-2.24.4-$system.tar.xz
fi

tarball=$tmpDir/nix-2.24.4-$system.tar.xz

require_util tar "unpack the binary tarball"
if [ "$(uname -s)" != "Darwin" ]; then
    require_util xz "unpack the binary tarball"
fi

if command -v curl > /dev/null 2>&1; then
    fetch() { curl --fail -L "$1" -o "$2"; }
elif command -v wget > /dev/null 2>&1; then
    fetch() { wget "$1" -O "$2"; }
else
    oops "you don't have wget or curl installed, which I need to download the binary tarball"
fi

echo "downloading Nix 2.24.4 binary tarball for $system from '$url' to '$tmpDir'..."
fetch "$url" "$tarball" || oops "failed to download '$url'"

if command -v sha256sum > /dev/null 2>&1; then
    hash2="$(sha256sum -b "$tarball" | cut -c1-64)"
elif command -v shasum > /dev/null 2>&1; then
    hash2="$(shasum -a 256 -b "$tarball" | cut -c1-64)"
elif command -v openssl > /dev/null 2>&1; then
    hash2="$(openssl dgst -r -sha256 "$tarball" | cut -c1-64)"
else
    oops "cannot verify the SHA-256 hash of '$url'; you need one of 'shasum', 'sha256sum', or 'openssl'"
fi

if [ "$hash" != "$hash2" ]; then
    oops "SHA-256 hash mismatch in '$url'; expected $hash, got $hash2"
fi

unpack=$tmpDir/unpack
mkdir -p "$unpack"
tar -xJf "$tarball" -C "$unpack" || oops "failed to unpack '$url'"

script=$(echo "$unpack"/*/install)

[ -e "$script" ] || oops "installation script is missing from the binary tarball!"
export INVOKED_FROM_INSTALL_IN=1
"$script" "$@"

} # End of wrapping
