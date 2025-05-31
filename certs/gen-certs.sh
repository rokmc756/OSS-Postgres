openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=KR/ST=Seoul/L=Guro/O=VMware/OU=Tanzu/CN=jtest.pivotal.io/emailAddress=jomoon@pivotal.io" \
 -key ca.key \
 -out ca.crt

openssl genrsa -out server.key 4096

openssl req -sha512 -new \
    -subj "/C=KR/ST=Seoul/L=Guro/O=VMware/OU=Tanzu/CN=jtest.pivotal.io/emailAddress=jomoon@pivotal.io" \
    -key server.key \
    -out server.csr

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=jtest.pivotal.io
DNS.2=jtest.pivotal
DNS.3=rk8-master
EOF

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in server.csr \
    -out server.crt
