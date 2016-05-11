{# Import global parameters #}
{% import 'bootstrap/params.jinja' as params %}

{%- for provider in params.distros %}
{%- for distro in params.distros[provider] %}
{{ provider }}-{{ distro }}-provisioned:
  salt_cluster.node_{{ params.action }}:
    - name: {{ params.name }}-{{ params.type }}-{{ provider }}-{{ distro }}
    {%- if params.action == 'present' %}
    - profile: {{ provider }}-{{ distro }}
    {%- endif %}
{%- endfor %}
{%- endfor %}
