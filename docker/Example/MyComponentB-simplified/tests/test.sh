#!/bin/sh
curl -sf mycomponentb/pageB.html -o /tmp/pageB.html
grep change /tmp/pageB.html
