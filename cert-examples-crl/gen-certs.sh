#!/bin/bash
# Here is a variant to my “Howto: Make Your Own Cert With OpenSSL” method.
# This time, I needed a signing cert with a Certificate Revocation List (CRL) extension and an (empty)
# CRL. I used instructions from this post.

# 
rm -f 01.pem ca.key certindex.attr.old certserial.old ia.csr root.crl \
certindex certindex.old crlnumber ia.key ca.crt certindex.attr certserial \
crlnumber.old ia.crt ia.p12

# Adding a CRL extension to a certificate is not difficult,
# you just need to include a configuration file with one line.
# But creating a CRL file requires more steps, that’s why I needed this howto.
# The start of this howto is the same as my previous howto.

echo "First generate a 4096-bit long RSA key for our root CA and store it in file ca.key"
openssl genrsa -out ca.key 4096
echo ""

# If you want to password-protect this key, add option -des3.
# Next, Create our self-signed root CA certificate ca.crt; you’ll need to provide an identity for your root CA:
# openssl req -new -x509 -days 1826 -key ca.key -out ca.crt

echo "Next, Create our self-signed root CA certificate ca.crt; you’ll need to provide an identity for your root CA"
openssl req -new -x509 -days 1826 -key ca.key -out ca.crt -subj "/C=KR/ST=Seoul/L=Guro/O=VMware/OU=Tanzu/CN=jtest.pivotal.io/emailAddress=jomoon@pivotal.io"
echo ""

# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# What you are about to enter is what is called a Distinguished Name or a DN.
# There are quite a few fields but you can leave some blank
# For some fields there will be a default value,
# If you enter '.', the field will be left blank.
# The -x509 option is used for a self-signed certificate. 1826 days gives us a cert valid for 5 years.

echo "Ceate our subordinate CA that will be used for the actual signing. First, generate the key"
openssl genrsa -out ia.key 4096
echo ""

echo "Then, request a certificate for this subordinate CA:"
openssl req -new -key ia.key -out ia.csr -subj "/C=KR/ST=Seoul/L=Guro/O=VMware/OU=Tanzu/CN=jtest.pivotal.io/emailAddress=jomoon@pivotal.io"
echo ""

# You are about to be asked to enter information that will be incorporated into your certificate request.
# What you are about to enter is what is called a Distinguished Name or a DN.
# There are quite a few fields but you can leave some blank
# For some fields there will be a default value,
# Please enter the following 'extra' attributes to be sent with your certificate request
# A challenge password []:
# An optional company name []:

# Make sure the Common Name is different for both certs, otherwise you’ll get an error.
# Now, before we process the request for the subordinate CA certificate and get it signed by the root CA,
# we need to create a couple of files (this step is done with Linux; to create empty file certindex on Windows,
# you could use Notepad in stead of touch).

touch certindex
echo 01 > certserial
echo 01 > crlnumber

# And also create this configuration file (ca.conf):
# Mainly copied from:
# http://swearingscience.com/2009/01/18/openssl-self-signed-ca/
# ~~~~~~~
# ca.conf
# ~~~~~~~

# Notice the crlDistributionPoints and DNS. entries pointing to domain example.com. You should change them to your domain.
# Now you can sign the request:

openssl ca -batch -config ca.conf -notext -in ia.csr -out ia.crt


# Using configuration from ca.conf
# Check that the request matches the signature
# Signature ok
# The Subject's Distinguished Name is as follows
# Certificate is to be certified until May  3 21:13:02 2015 GMT (730 days)

# Write out database with 1 new entries
# Data Base Updated
# To use this subordinate CA key for Authenticode signatures with Microsoft’s signtool, you’ll have to package the keys and certs in a PKCS12 file:

# Enter Export Password:
# Verifying - Enter Export Password:
# openssl pkcs12 -export -out ia.p12 -inkey ia.key -in ia.crt -chain -CAfile ca.crt 
openssl pkcs12 -export -out ia.p12 -inkey ia.key -in ia.crt -chain -CAfile ca.crt \
-passout pass: -passin pass:""

# Finally, you can generate the empty CRL file:
openssl ca -config ca.conf -gencrl -keyfile ca.key \
-cert ca.crt -out root.crl.pem


openssl crl -inform PEM -in root.crl.pem -outform DER -out root.crl
rm root.crl.pem


# rm is a Linux command, use del on a Windows machine.
# The last step is to host this root.crl file on the webserver pointed to in the CRL extension (http://example.com/root.crl in this example).
# If you need to revoke the intermediate certificate, use this command:

openssl ca -config ca.conf -revoke ia.crt -keyfile ca.key -cert ca.crt

exit

# And then regenerate the CRL file like explained above.

# https://www.golinuxcloud.com/revoke-certificate-generate-crl-openssl/
# https://blog.didierstevens.com/2013/05/08/howto-make-your-own-cert-and-revocation-list-with-openssl/
# https://www.ibm.com/docs/en/hpvs/1.2.x?topic=reference-openssl-configuration-examples
# https://jamielinux.com/docs/openssl-certificate-authority/appendix/root-configuration-file.html
# https://superuser.com/questions/1618693/openssl-using-passin-or-passout-when-there-is-no-password

