docker build `
 -t $Env:dockerID/ws-verify `
 $pwd\verify;

docker run --rm $Env:dockerID/ws-verify;
