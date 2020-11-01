awk -f prettify_commandgen.awk flow.txt metadata.txt
./prettify_run.sh
rm book-template -rf
rm prettify_run.sh
