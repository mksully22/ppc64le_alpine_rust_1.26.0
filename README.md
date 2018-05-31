# Compiling Rust for Alpine

This repository contains the source, patches, scripts, and bootstrap packages (Cargo and Rustc) need to compile rust on Alpine.

[Rust]: https://www.rust-lang.org

## Instructions
1. Create a docker container with Alpine 

    sudo docker run --name alpine_rustbuild  -it alpine:3.7
    
2. Enter alpine_rustbuild container

    sudo docker exec -it alpine_rustbuild  /bin/sh
    
3. Inside the alpine_rustbuild docker container:

   a. Modify /etc/apk/repositories to point to edge
   
   b. apk update; apk upgrade
   
   c. Copy the contents of this project to /root/test26  directory
   
   d. as root, /root/test26/build_rust26.sh

Note: rust versions 1.24.1, 1.26.0, and 1.26.1 source can be built successfully for ppc64le. However the 1.25.0 level encountered multiple build errors. This archive contains rust and cargo apk 1.26.0 packages that were built successfully on Alpine and are used as bootstraps

Note: When using the abuild process multiple testcase errors occur during the check() phase that need further investigation.
