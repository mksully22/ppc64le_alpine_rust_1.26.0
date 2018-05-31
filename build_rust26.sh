#
# Usage:
# $ sudo docker run --name alpine_rustbuiild  -it -v /rust-alpine-ppc64le:/mnt alpine:3.7
# $ sudo docker exec -it alpine_rustbuild  /bin/bash
# $ sudo docker ps
# In container:
#   apk update
#   apk upgrade
#   Copy build_rust.sh and all patches to /root/test26/.
# # Invoke /root/test26/build_rust.sh
# TODOS:

set -ex

user=rustbuild
sourcedir=/root/test26

as_user() {
    su -c 'bash -c "'"${@}"'"' $user
}

mk_user() {
    adduser -D $user
}

fetch_rust() {
    cd /home/$user; rm -rf /home/$user/test26; cp -r $sourcedir /home/$user/.; chown -R rustbuild:rustbuild /home/$user/test26;
    as_user "
    rm -rf ~/rust; tar -xzf ~/test26/rustc-1.26.0-src.tar.gz;
    mv rustc-1.26.0-src rust
    rm -rf ~/.cargo
"
}

install_deps() {
        apk add alpine-sdk gcc llvm-libunwind-dev cmake file libffi-dev llvm5-dev llvm5-test-utils python2 tar zlib-dev gcc llvm-libunwind-dev musl-dev util-linux bash
        apk add --allow-untrusted $sourcedir/rust-stdlib-1.26.0-r2.apk $sourcedir/rust-1.26.0-r2.apk $sourcedir/cargo-1.26.0-r2.apk
}

apply_patches() {
    # TODO upstream these patches to rust-lang/llvm
    as_user "
cd ~/rust
rm -Rf src/llvm/
patch -p1 -b < ~/test26/minimize-rpath.patch
patch -p1 -b < ~/test26/static-pie.patch
patch -p1 -b < ~/test26/need-rpath.patch
patch -p1 -b < ~/test26/musl-fix-static-linking.patch
patch -p1 -b < ~/test26/musl-fix-linux_musl_base.patch
patch -p1 -b < ~/test26/llvm-with-ffi.patch
patch -p1 -b < ~/test26/alpine-target.patch
patch -p1 -b < ~/test26/alpine-move-py-scripts-to-share.patch
patch -p1 -b < ~/test26/alpine-change-rpath-to-rustlib.patch
patch -p1 -b < ~/test26/s7_ppc64le_target.patch
patch -p1 -b < ~/test26/fix-configure-tools.patch
patch -p1 -b < ~/test26/bootstrap-tool-respect-tool-config.patch
patch -p1 -b < ~/test26/ensure-stage0-libs-have-unique-metadata.patch
patch -p1 -b < ~/test26/install-template-shebang.patch
patch -p1 -b < ~/test26/cargo-libressl27x.patch
patch -p1 -b < ~/test26/cargo-tests-fix-build-auth-http_auth_offered.patch
patch -p1 -b < ~/test26/cargo-tests-ignore-resolving_minimum_version_with_transitive_deps.patch
patch -p1 -b < ~/test26/s7_cargo_libc_modrs.patch
patch -p1 -b < ~/test26/s7_cargo_libc_b32modrs.patch
patch -p1 -b < ~/test26/s7_cargo_libc_b64modrs.patch
patch -p1 -b < ~/test26/s7_cargo_libc_b64x86_64.patch
patch -p1 -b < ~/test26/s8_cargo_libc_b64powerpc64le.patch
patch -p1 -b < ~/test26/s7_liblibc_modrs.patch
patch -p1 -b < ~/test26/s7_liblibc_b32modrs.patch
patch -p1 -b < ~/test26/s7_liblibc_b64modrs.patch
patch -p1 -b < ~/test26/s7_liblibc_b64x86_64.patch
patch -p1 -b < ~/test26/s8_liblibc_b64powerpc64.patch
patch -p1 -b < ~/test26/s8_cargo_libc_checksum.patch
#patch -p1 -b <  ~/test26/migration_from_1.24.0_to_1.26.0.patch 
"
}


mk_rustc() {
    dir=$(pwd)
    as_user "
cd ~/rust
./configure \
                --build="powerpc64le-alpine-linux-musl" \
                --host="powerpc64le-alpine-linux-musl" \
                --target="powerpc64le-alpine-linux-musl" \
                --prefix="/usr" \
                --release-channel="stable" \
                --enable-local-rust \
                --local-rust-root="/usr" \
                --llvm-root="/usr/lib/llvm5" \
                --musl-root="/usr" \
                --disable-docs \
                --enable-extended \
		--enable-llvm-link-shared \
		--enable-option-checking \
		--enable-locked-deps \
		--enable-vendor \
                --disable-jemalloc

                unset MAKEFLAGS
                date > build_dist.log
                RUSTFLAGS='$RUSTFLAGS -A warnings'  RUST_BACKTRACE=1 RUSTC_CRT_STATIC="false" taskset 0x1 ./x.py dist -j1 -v >> build_dist.log 2>&1
                date >> build_dist.log
"
}


main() {
   mk_user
   install_deps
   fetch_rust
   apply_patches
   mk_rustc
}

main
