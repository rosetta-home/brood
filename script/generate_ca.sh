PASSWORD="PASSWORD"

# Make the config CA specific
cat openssl.conf > use.conf
echo "CN=CRTLabs" >> use.conf

# Create the necessary files
mkdir keys requests certs
touch database.txt
echo 01 > serial.txt

# Generate your CA key (Use appropriate bit size here for your situation)
openssl genrsa -aes256 -out keys/ca.key -passout pass:$PASSWORD 2048

# Generate your CA req
openssl req -config use.conf -new -key keys/ca.key -out requests/ca.req -passin pass:$PASSWORD

# Make your self-signed CA certificate
openssl ca  -config use.conf -selfsign -keyfile keys/ca.key -out certs/ca.crt -in requests/ca.req -extensions v3_ca -passin pass:$PASSWORD -batch

# Cleanup
rm requests/ca.req use.conf
