#!/bin/bash
ps axc|awk "{if ((\$5==\"Wirecast\")) print \$5}"