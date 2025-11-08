#!/usr/bin/env bash
awk '{print int($1/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime
