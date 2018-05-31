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
