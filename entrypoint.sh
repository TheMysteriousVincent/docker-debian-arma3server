#!/bin/bash

args () {
    case $1 in
    "install")
        install
        ;;
    "start")
        start
        ;;
    
}

args $1
