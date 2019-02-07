#!/usr/bin/env bash
set -Eeuo pipefail

rm -rf ~/Documents/Adobe
sudo rm -rf /Library/Application\ Support/Adobe*
sudo rm -rf /Library/Application\ Support/regid.*.com.adobe
sudo rm -rf /Library/Caches/com.{a,A}dobe*
sudo rm -rf /Library/Fonts/{a,A}dobe*
sudo rm -rf /Library/Preferences/com.{a,A}dobe*
sudo rm -rf /Library/ScriptingAdditions/Adobe\ Unit\ Types.osax
sudo rm -rf /Users/Shared/Adobe
sudo rm -rf ~/Library/Application\ Support/Adobe*
sudo rm -rf ~/Library/Caches/Adobe*
sudo rm -rf ~/Library/Caches/com.adobe*
sudo rm -rf ~/Library/Preferences/Adobe*
sudo rm -rf ~/Library/Preferences/ByHost/com.adobe*
sudo rm -rf ~/Library/Preferences/com.{a,A}dobe*
sudo rm -rf ~/Library/Preferences/Macromedia
sudo rm -rf ~/Library/Saved\ Application\ State/com.{a,A}dobe*
