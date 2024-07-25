#!/bin/sh
if [ ! -d "bin" ]; then
    mkdir bin
fi

bun install
bun build ./fetch_token.js --compile --minify --outfile fetch_token   
