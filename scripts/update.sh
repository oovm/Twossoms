#!/usr/bin/env bash
cd ..
git submodule foreach git pull
git submodule foreach git submodule update --remote
yarn upgrade --latest

sleep 60