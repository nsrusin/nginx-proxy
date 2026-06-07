#!/usr/bin/env python3

import os
import sys
import json
from jinja2.environment import Environment
from jinja2.loaders import FileSystemLoader

if len(sys.argv) < 2:
    raise Exception("Run like: ./templator.py template.yaml.j2 template.yaml")

template_file = sys.argv[1]
if len(sys.argv) > 2:
    dest_file = sys.argv[2]
else:
    dest_file = None

templates_dir = os.path.dirname(template_file)
template_file = os.path.basename(template_file)

loader = FileSystemLoader(searchpath=templates_dir)
template_env = Environment(loader=loader, trim_blocks=True)
template_env.filters['fromjson'] = json.loads
template = template_env.get_template(template_file)
output = template.render(os.environ)

if dest_file:
    with open(dest_file, 'w') as f:
        f.write(output) 
else:
    print(output)
