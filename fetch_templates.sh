#!/bin/bash
mkdir -p wiki_resources
echo '<?xml version="1.0" encoding="UTF-8"?>' > wiki_resources/fandom_templates.xml
echo '<mediawiki xmlns="http://www.mediawiki.org/xml/export-0.10/" version="0.10" xml:lang="en">' >> wiki_resources/fandom_templates.xml

while IFS= read -r page; do
  echo "Fetching $page"
  ns=10
  if [[ "$page" == Module:* ]]; then ns=828; fi

  encoded_page=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$page")

  content=$(curl -s "https://visceraleds-scp-site-roleplay.fandom.com/api.php?action=query&prop=revisions&rvprop=content&format=json&titles=$encoded_page" \
            | jq -r '.query.pages[]?.revisions[0]["*"] // .query.pages[]?.revisions[0].slots.main["*"] // ""')

  content_escaped=$(echo "$content" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')

  # append page without indentation
  cat >> wiki_resources/fandom_templates.xml <<EOF
<page>
<title>$page</title>
<ns>$ns</ns>
<revision>
<text xml:space="preserve">$content_escaped</text>
</revision>
</page>
EOF

done < pagelist.txt

echo '</mediawiki>' >> wiki_resources/fandom_templates.xml
