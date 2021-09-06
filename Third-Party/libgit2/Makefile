################################################################################
# The MIT License (MIT)
# 
# Copyright (c) 2021 Jean-David Gadina - www-xs-labs.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################################################

REPOS_URL := https://github.com/libgit2/libgit2.git
DIR_SRC   := $(realpath .)/source/
DIR_INC   := $(realpath .)/include/
DIR_LIB   := $(realpath .)/lib/
DIR_BUILD := $(realpath .)/build/

.PHONY: clean clone update build

all: clone update build
	
	@:
	
clean:
	
	@rm -rf $(DIR_BUILD)/*

clone:
	
	@if [ ! -d $(DIR_SRC) ]; then git clone --recursive $(REPOS_URL) $(DIR_SRC); fi

update:
	
	@cd $(DIR_SRC) && git pull
	
build: build_x86_64 build_arm64
	
	@lipo -create -output $(DIR_LIB)/libgit2.a $(DIR_BUILD)/arm64/libgit2.a $(DIR_BUILD)/x86_64/libgit2.a
	@rm -rf $(DIR_INC)
	@cp -r $(DIR_SRC)/include $(DIR_INC)

build_%: _FLAGS_DEPLOY_TARGET = 11.0
build_%: _FLAGS_ARCH          = -target $*-apple-macos11.0
build_%: _FLAGS_STDLIB        = -stdlib=libc++
build_%:
	
	@mkdir -p $(DIR_BUILD)/$*
	@cd $(DIR_BUILD)/$* && cmake -DLIBSSH2_FOUND=1 -DOPENSSL_ROOT_DIR=$(realpath .)/../openssl -DOPENSSL_CRYPTO_LIBRARY=$(realpath .)/../openssl -DOPENSSL_INCLUDE_DIR=$(realpath .)/../openssl/include -DCMAKE_OSX_ARCHITECTURES=$* -DMACOSX_DEPLOYMENT_TARGET=$(_FLAGS_DEPLOY_TARGET) -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release -DTHREADSAFE=ON -DBUILD_CLAR=OFF -DCMAKE_C_FLAGS="-arch $* -mmacosx-version-min=$(_FLAGS_DEPLOY_TARGET) -I$(realpath .)/../libssh2/include" -DCMAKE_CXX_FLAGS="-arch $* -mmacosx-version-min=$(_FLAGS_DEPLOY_TARGET) -$(_FLAGS_STDLIB) -I$(realpath .)/../libssh2/include" $(DIR_SRC)
	@cd $(DIR_BUILD)/$* && cmake --build .
