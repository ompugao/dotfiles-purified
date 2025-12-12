#!/bin/bash
proxy=$(1:-localhost:8080)
env http_proxy=socks5h://${proxy} HTTPS_PROXY=socks5h://${proxy} ALL_PROXY=socks5h://${proxy} onedrive -m
