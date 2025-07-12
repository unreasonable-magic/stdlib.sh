#!/usr/bin/env bash

sqlite3 test/fixtures/northwind.db "select OrderID, ShipName, ShipCity, ShipCountry from orders limit 30" -csv | stdlib ui/table
