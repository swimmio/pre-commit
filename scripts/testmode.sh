#!/bin/bash

# This simply flips *this* repository into a state that
# will cause verification to fail, or restore it. Think
# of it like a rocker switch. Here for development.

# It causes the verification to instantly fail because
# no .swm folder exists.

if [ -d ".swm" ]; then
    echo "Test mode off. Turning on."
    mv .swm .swm-disabled
else
    echo "Test mode on. Turning off."
    mv .swm-disabled .swm
fi