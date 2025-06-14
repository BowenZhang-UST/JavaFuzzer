SUITE_NAME=$1
if [ -z "$SUITE_NAME" ]; then
    echo suite name missing.
    exit
else
    mkdir $SUITE_NAME
fi
export JAVA_HOME="/Users/bowen/Desktop/jellyfish-translator/jdk/Contents/Home"
./mrt.sh -R $SUITE_NAME -P test -NT 20 -NP 50 -A -conf $SUITE_NAME.yml -sp

COUNT=0
for subdir in $SUITE_NAME/passes/*; do
    COUNT=$((COUNT + 1))
    echo $subdir
    "$JAVA_HOME/bin/jar" cf "${subdir}/Test.jar" -C "${subdir}" Test.class -C "${subdir}" FuzzerUtils.class
    mv $subdir $SUITE_NAME/passes/test${COUNT}
done