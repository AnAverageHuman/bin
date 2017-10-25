#!/usr/bin/env python
from datetime import datetime
import ephem

d = datetime.today().date()
m = {}

for i in ['new', 'full', 'first quarter', 'last quarter']:
    m[i] = ephem.localtime(
        getattr(ephem, 'next_' + i.replace(' ', '_') + '_moon')(d)).date()

for k, v in sorted(m.items(), key=lambda x: x[1]):
    if v == d:
        print("{} moon tonight!".format(k.title()))
    else:
        print("Next {} moon: {}".format(k, v))
