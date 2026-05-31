#!/usr/bin/env python3
"""Extracts relationships and data flows from a LikeC4 JSON model export.

Usage:
    python3 scripts/extract-labels.py <model.json>

Output:
    - All relationships with source, target, title, protocol
    - All INF data flows with codes and descriptions
"""

import json
import re
import sys


def extract_from_json(filepath):
    with open(filepath) as f:
        data = json.load(f)

    # Handle LikeC4 JSON export structure
    # The model has: elements, relations, views
    relations = data.get('relations', {})
    elements = data.get('elements', {})

    # Build element ID → title lookup
    element_titles = {}
    for eid, el in elements.items():
        element_titles[eid] = el.get('title', eid)

    # Extract relationships
    print(f'=== RELATIONSHIPS ({len(relations)} total) ===')
    protocols = []
    inf_flows = []

    for rid, rel in relations.items():
        source_id = rel.get('source', {}).get('model', '?')
        target_id = rel.get('target', {}).get('model', '?')
        title = rel.get('title', '')
        desc = rel.get('description', {}).get('txt', '')

        source_name = element_titles.get(source_id, source_id)
        target_name = element_titles.get(target_id, target_id)

        # Determine protocol from description
        protocol = desc if desc else '(no protocol)'

        # Check if this is an INF data flow
        inf_match = re.match(r'INF(\d+)\.\s*(.*)', title)
        if inf_match:
            inf_num = int(inf_match.group(1))
            inf_desc = inf_match.group(2)
            inf_flows.append((inf_num, title, source_name, target_name))
        else:
            protocols.append(protocol)

        print(f'  [{protocol}] {source_name} -> {target_name}: {title}')

    # Summary
    print(f'\n=== SUMMARY ===')
    print(f'Total relationships: {len(relations)}')

    if protocols:
        print(f'\nNon-INF relationships ({len(protocols)}):')
        from collections import Counter
        for proto, count in Counter(protocols).most_common():
            print(f'  [{proto}]: {count}')

    if inf_flows:
        print(f'\nINF data flows ({len(inf_flows)}):')
        inf_flows.sort(key=lambda x: x[0])
        for num, title, src, tgt in inf_flows:
            print(f'  {title}')
        print(f'  Unique INF codes: {len(inf_flows)}')

    print(f'\nNon-INF arrow count: {len(protocols)}')
    print(f'INF flow count: {len(inf_flows)}')
    print(f'Consistent: {"✓" if len(protocols) == len(inf_flows) else "✗ NOT consistent"}')

    return len(protocols), len(inf_flows)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <model.json>', file=sys.stderr)
        sys.exit(1)

    arrows, infs = extract_from_json(sys.argv[1])

    if arrows != infs:
        sys.exit(1)
