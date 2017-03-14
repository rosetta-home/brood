PASSWORD="PASSWORD"
NAME="Cicada"

# Make the config Client specific
cat openssl.conf > use.conf
echo "CN=$NAME" >> use.conf

openssl req -new -nodes -extensions client -out "requests/$NAME.req" -keyout "$NAME.key" -config use.conf -passin pass:$PASSWORD
openssl ca -batch -extensions client -keyfile keys/ca.key -cert certs/ca.crt -config use.conf -out "certs/$NAME.crt" -passin pass:$PASSWORD -infiles "requests/$NAME.req"

# Cleanup
rm "requests/$NAME.req" use.conf
