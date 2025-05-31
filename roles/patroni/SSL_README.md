When I create the certs in the lab, I can get it to work as expected. If we use the same method to create the certs on your cluster, hopefully it will work.
In the directory /data1/data_prod/own :
Create the file "ssl.conf" with the contents
[CA_default]
copy_extensions = copy

[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = req_distinguished_name
x509_extensions = v3_ca

[req_distinguished_name]
C = US
ST = PA
L = Reading
O = Penske Truck Leasing
OU = Patroni
emailAddress = it@penske.com
CN = penske.com

[v3_ca]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
subjectAltName = @alternate_names

[alternate_names]
DNS.1 = localhost
DNS.2 = *.localhost
Create the file "server_cert_ext.conf"  with the contents:We will need to replace the "<HOSTX>" with the FQDN of the 3 servers.
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = digitalSignature, keyEncipherment
#extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = <HOST1>
DNS.2 = <HOST2>
DNS.3 = <HOST3>
Then run the commands:
openssl genrsa -out server.key 4096
openssl req -key server.key -new -out server.csr
openssl x509 -req -in server.csr -CA ./root.crt -CAkey ./root.key -out server.crt -CAcreateserial -days 3650 -extfile server_cert_ext.conf 
openssl x509 -text -noout -in server.crt 

We will copy the files "root.crt", "server.crt" and "server.key" to the 3 hosts and change the configs to use the new files.
Then restart and hopefully it will work as in my lab.

Regards,
joe.


https://docs.microfocus.com/doc/Operations_Orchestration/2022.11/HardeningPatroniCluster

