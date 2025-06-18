BC_DIR=$1
ORACLE_DIR=$2

if [ -z "$BC_DIR" ]; then
    echo Bitcode directory missing
    exit
fi
if [ -z "$ORACLE_DIR" ]; then
    echo Oracle directory missing
    exit
fi

COUNT=0
for i in {1..1000}
do
    diff -q $BC_DIR/test${i}/out.txt $ORACLE_DIR/passes/test${i}/rt_out > /dev/null
    if [ $? -ne 0 ]; then
        echo $BC_DIR/test${i}/out.txt $ORACLE_DIR/passes/test${i}/rt_out
        COUNT=$((COUNT + 1))
    fi
done

echo "---TOTAL ERRORS: ${COUNT}----"