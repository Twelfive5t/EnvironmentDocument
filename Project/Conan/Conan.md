# Conan使用文档

```sh
conan build . --build=missing -pr:a=conanfile/debug_linux
conan export-pkg . -pr:a=conanfile/debug_linux
conan upload acrn_rtos/2.1.0@rtos/acrn -r embedded-linux
# name/version@user/channel
```

```sh
git clone https://github.com/conan-io/conan-center-index.git
wget https://github.com/google/googletest/archive/v1.14.0.tar.gz -O gtest-1.14.0.tar.gz
sha256sum gtest-1.14.0.tar.gz
conan create . --name=gtest --version=1.14.0 --user=third_party --channel=acrn --build=missing -pr:a=conan_profile/debug_linux
conan upload gtest/1.14.0@third_party/acrn -r embedded-linux
```
