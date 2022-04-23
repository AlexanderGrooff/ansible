// {{ ansible_managed }}

// We remove ungrouped
roles: {{ group_names | replace("'", "\"") | replace('"ungrouped"', "")}}
