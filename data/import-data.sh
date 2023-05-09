#!/usr/bin/env bash

mongoimport --db test --collection restaurant --drop --file /restaurant.json
