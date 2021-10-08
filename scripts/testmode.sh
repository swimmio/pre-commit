#!/bin/bash

# This simply flips *this* repository into a state that
# will cause verification to fail, or restore it. Think
# of it like a rocker switch. Here for development.

if [ -d ".swm" ]; then
    echo "Test mode off. Turning on."
    mv .swm .swm1
else
    echo "Test mode on. Turning off."
    mv .swm1 .swm
fi