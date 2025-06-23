SUITE_NAME=$1
if [ -z "$SUITE_NAME" ]; then
    echo suite name missing.
    exit
fi

echo ---$SUITE_NAME--- > err.txt
for subdir in $SUITE_NAME/*; do
    echo $subdir
    ../llvm-12/bin/llvm-dis $subdir/javafuzzer.bc 
    python3 ../python/linker/jellyfish-link.py ./lib.ll $subdir/javafuzzer.ll -o $subdir/all.ll

    ../llvm-12/bin/clang -O3 -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib $subdir/all.ll -o $subdir/a.out 

    timeout 60s $subdir/a.out > $subdir/out.txt
    if [ $? -ne 0 ]; then
        echo $subdir >> err.txt
    fi
done