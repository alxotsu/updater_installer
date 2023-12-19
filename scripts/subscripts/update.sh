#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}
