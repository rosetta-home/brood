In order to sign client certificates, you will need a CA certificate you control. Paying for one is out of the question in most cases, as global-trusted CA certificates are a security hazard for the rest of the Internet. So in these cases you have to make your own CA and create your own server and client certificates.

So let's start with a basic openssl.conf file that we will use for generation of all these certificates:

[ ca ]
default_ca  = CA_default                # The default ca section

[ CA_default ]
certs          = certs                  # Where the issued certs are kept
crl_dir        = crl                    # Where the issued crl are kept
database       = database.txt           # database index file.
new_certs_dir  = certs                  # default place for new certs.
certificate    = cacert.pem             # The CA certificate
serial         = serial.txt             # The current serial number
crl            = crl.pem                # The current CRL
private_key    = private\cakey.pem      # The private key
RANDFILE       = private\private.rnd    # private random number file

x509_extensions  = v3_usr               # The extentions to add to the cert
default_days     = 365
default_crl_days = 30                   # how long before next CRL
default_md       = sha256               # which md to use.
preserve         = no                   # keep passed DN ordering
policy           = policy_match
email_in_dn      =

[ policy_match ]
commonName      = supplied

[ req ]
default_bits        = 2048
default_keyfile     = privkey.pem
distinguished_name  = req_distinguished_name
x509_extensions     = v3_ca

[ v3_ca ]
basicConstraints     = CA:TRUE
subjectKeyIdentifier = hash

[ v3_usr ]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash

[ server ]
basicConstraints       = CA:FALSE
nsCertType             = server
nsComment              = "Server Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage       = serverAuth
keyUsage               = digitalSignature, keyEncipherment

[ client ]
basicConstraints       = CA:FALSE
nsCertType             = client
nsComment              = "Client Certificate"
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage       = clientAuth
keyUsage               = digitalSignature

[ req_distinguished_name ]
This config file is made for automatic generation of certificates from a batch script. If you need more control or naming options, you need to adapt it to your situation.

So for generating a CA, go to the directory where you want to make your CA, put openssl.conf there and:

PASSWORD="PUT_YOUR_CA_PASSWORD_HERE"

# Make the config CA specific
cat openssl.conf > use.conf
echo "CN=PUT_CA_NAME_HERE" >> use.conf

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
Now to generate a server certificate (e.g. for your web server):

PASSWORD="PUT_YOUR_CA_PASSWORD_HERE"
NAME="PUT_THE_NAME_OF_SERVER_TO_GENERATE_HERE"

# Make the config Server specific
cat openssl.conf > use.conf
echo "CN=$NAME" >> use.conf

openssl req -new -nodes -extensions server -out "requests/$NAME.req" -keyout "$NAME.key" -config use.conf -passin pass:$PASSWORD )
openssl ca -batch -extensions server -keyfile keys/ca.key -cert certs/ca.crt -config use.conf -out "certs/$NAME.crt" -passin pass:$PASSWORD -infiles "requests/$NAME.req"

# Cleanup
rm "requests/$NAME.req" use.conf
Now to generate a client certificate:

PASSWORD="PUT_YOUR_CA_PASSWORD_HERE"
NAME="PUT_THE_NAME_OF_CLIENT_TO_GENERATE_HERE"

# Make the config Client specific
cat openssl.conf > use.conf
echo "CN=$NAME" >> use.conf

openssl req -new -nodes -extensions client -out "requests/$NAME.req" -keyout "$NAME.key" -config use.conf -passin pass:$PASSWORD )
openssl ca -batch -extensions client -keyfile keys/ca.key -cert certs/ca.crt -config use.conf -out "certs/$NAME.crt" -passin pass:$PASSWORD -infiles "requests/$NAME.req"

# Cleanup
rm "requests/$NAME.req" use.conf
The only difference between generating keys and certificates for clients and servers it to prevent that a stolen client certificate can also be used to play a server and 'fool' other clients to connect to it (this only works as long as your applications support the client and server extension in certificates).
