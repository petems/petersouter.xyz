+++
author = "Peter Souter"
categories = ["Tech", "Blog", "Terraform", "Puppet"]
date = 2020-10-20T12:07:00Z
description = ""
draft = false
thumbnailImage = "/images/2020/10/vault-cert-info-750.png"
coverImage = "/images/2020/10/vault-cert-info.png"
slug = "enjoying-vault-cert-management"
tags = ["Tech", "Blog", "Vault"]
title = "Enjoying the mangement of Vault Certs with vault-cert-info"
+++

One of my favourite things is writing glue-code or little utility apps and I've been tinkering with something to help with the Vault PKI secrets engine. 

## Vault PKI Engine

Vault has a PKI secrets engine, which allows generation of dynamic X.509 certificates. It's probably the most popular use-case for Vault after KV, as manging certs manually is a big of a pain and requires 

It's pretty quick to get off the ground as well.

For our testing, we'll simply start Vault in dev mode with a pre-determined root token:

```
$ VAULT_DEV_ROOT_TOKEN_ID=ROOT vault server -dev &
```

From here, we can export our environment varialbes:

```
$ export VAULT_TOKEN=ROOT
$ export VAULT_ADDR='http://127.0.0.1:8200'
```

And now, we can quickly setup a PKI engine with just a few commands:

```
$ vault secrets enable pki
Successfully mounted 'pki' at 'pki'!
$ vault write pki/root/generate/internal common_name=myvault.com ttl=87600h
Key             Value
---             -----
certificate     -----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUJqrw/9EDZbp4DExaLjh0vSAHyBgwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLbXl2YXVsdC5jb20wHhcNMTcxMjA4MTkyMzIwWhcNMjcx
MjA2MTkyMzQ5WjAWMRQwEgYDVQQDEwtteXZhdWx0LmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKY/vJ6sRFym+yFYUneoVtDmOCaDKAQiGzQw0IXL
wgMBBb82iKpYj5aQjXZGIl+VkVnCi+M2AQ/iYXWZf1kTAdle4A6OC4+VefSIa2b4
eB7R8aiGTce62jB95+s5/YgrfIqk6igfpCSXYLE8ubNDA2/+cqvjhku1UzlvKBX2
hIlgWkKlrsnybHN+B/3Usw9Km/87rzoDR3OMxLV55YPHiq6+olIfSSwKAPjH8LZm
uM1ITLG3WQUl8ARF17Dj+wOKqbUG38PduVwKL5+qPksrvNwlmCP7Kmjncc6xnYp6
5lfr7V4DC/UezrJYCIb0g/SvtxoN1OuqmmvSTKiEE7hVOAcCAwEAAaN7MHkwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFECKdYM4gDbM
kxRZA2wR4f/yNhQUMB8GA1UdIwQYMBaAFECKdYM4gDbMkxRZA2wR4f/yNhQUMBYG
A1UdEQQPMA2CC215dmF1bHQuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCCJKZPcjjn
7mvD2+sr6lx4DW/vJwVSW8eTuLtOLNu6/aFhcgTY/OOB8q4n6iHuLrEt8/RV7RJI
obRx74SfK9BcOLt4+DHGnFXqu2FNVnhDMOKarj41yGyXlJaQRUPYf6WJJLF+ZphN
nNsZqHJHBfZtpJpE5Vywx3pah08B5yZHk1ItRPEz7EY3uwBI/CJoBb+P5Ahk6krc
LZ62kFwstkVuFp43o3K7cRNexCIsZGx2tsyZ0nyqDUFsBr66xwUfn3C+/1CDc9YL
zjq+8nI2ooIrj4ZKZCOm2fKd1KeGN/CZD7Ob6uNhXrd0Tjwv00a7nffvYQkl/1V5
BT55jevSPVVu
-----END CERTIFICATE-----
expiration      1828121029
issuing_ca      -----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUJqrw/9EDZbp4DExaLjh0vSAHyBgwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLbXl2YXVsdC5jb20wHhcNMTcxMjA4MTkyMzIwWhcNMjcx
MjA2MTkyMzQ5WjAWMRQwEgYDVQQDEwtteXZhdWx0LmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKY/vJ6sRFym+yFYUneoVtDmOCaDKAQiGzQw0IXL
wgMBBb82iKpYj5aQjXZGIl+VkVnCi+M2AQ/iYXWZf1kTAdle4A6OC4+VefSIa2b4
eB7R8aiGTce62jB95+s5/YgrfIqk6igfpCSXYLE8ubNDA2/+cqvjhku1UzlvKBX2
hIlgWkKlrsnybHN+B/3Usw9Km/87rzoDR3OMxLV55YPHiq6+olIfSSwKAPjH8LZm
uM1ITLG3WQUl8ARF17Dj+wOKqbUG38PduVwKL5+qPksrvNwlmCP7Kmjncc6xnYp6
5lfr7V4DC/UezrJYCIb0g/SvtxoN1OuqmmvSTKiEE7hVOAcCAwEAAaN7MHkwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFECKdYM4gDbM
kxRZA2wR4f/yNhQUMB8GA1UdIwQYMBaAFECKdYM4gDbMkxRZA2wR4f/yNhQUMBYG
A1UdEQQPMA2CC215dmF1bHQuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCCJKZPcjjn
7mvD2+sr6lx4DW/vJwVSW8eTuLtOLNu6/aFhcgTY/OOB8q4n6iHuLrEt8/RV7RJI
obRx74SfK9BcOLt4+DHGnFXqu2FNVnhDMOKarj41yGyXlJaQRUPYf6WJJLF+ZphN
nNsZqHJHBfZtpJpE5Vywx3pah08B5yZHk1ItRPEz7EY3uwBI/CJoBb+P5Ahk6krc
LZ62kFwstkVuFp43o3K7cRNexCIsZGx2tsyZ0nyqDUFsBr66xwUfn3C+/1CDc9YL
zjq+8nI2ooIrj4ZKZCOm2fKd1KeGN/CZD7Ob6uNhXrd0Tjwv00a7nffvYQkl/1V5
BT55jevSPVVu
-----END CERTIFICATE-----
serial_number   26:aa:f0:ff:d1:03:65:ba:78:0c:4c:5a:2e:38:74:bd:20:07:c8:18
$ vault write pki/config/urls issuing_certificates="http://vault.example.com:8200/v1/pki/ca" crl_distribution_points="http://vault.example.com:8200/v1/pki/crl"
```

We then configure a role to allow the creation of certs:

```
$ vault write pki/roles/example-dot-com \
    allowed_domains=example.com \
    allow_subdomains=true max_ttl=72h
Success! Data written to: pki/roles/example-dot-com
```

Then we can hit that role to generate a new cert:

```
$ vault write pki/issue/example-dot-com \
    common_name=blah.example.com
Key                 Value
---                 -----
certificate         -----BEGIN CERTIFICATE-----
MIIDvzCCAqegAwIBAgIUWQuvpMpA2ym36EoiYyf3Os5UeIowDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLbXl2YXVsdC5jb20wHhcNMTcxMjA4MTkyNDA1WhcNMTcx
MjExMTkyNDM1WjAbMRkwFwYDVQQDExBibGFoLmV4YW1wbGUuY29tMIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1CU93lVgcLXGPxRGTRT3GM5wqytCo7Z6
gjfoHyKoPCAqjRdjsYgp1FMvumNQKjUat5KTtr2fypbOnAURDCh4bN/omcj7eAqt
ldJ8mf8CtKUaaJ1kp3R6RRFY/u96BnmKUG8G7oDeEDsKlXuEuRcNbGlGF8DaM/O1
HFa57cM/8yFB26Nj5wBoG5Om6ee5+W+14Qee8AB6OJbsf883Z+zvhJTaB0QM4ZUq
uAMoMVEutWhdI5EFm5OjtMeMu2U+iJl2XqqgQ/JmLRjRdMn1qd9TzTaVSnjoZ97s
jHK444Px1m45einLqKUJ+Ia2ljXYkkItJj9Ut6ZSAP9fHlAtX84W3QIDAQABo4H/
MIH8MA4GA1UdDwEB/wQEAwIDqDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUH
AwIwHQYDVR0OBBYEFH/YdObW6T94U0zuU5hBfTfU5pt1MB8GA1UdIwQYMBaAFECK
dYM4gDbMkxRZA2wR4f/yNhQUMDsGCCsGAQUFBwEBBC8wLTArBggrBgEFBQcwAoYf
aHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAbBgNVHREEFDASghBibGFo
LmV4YW1wbGUuY29tMDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly8xMjcuMC4wLjE6
ODIwMC92MS9wa2kvY3JsMA0GCSqGSIb3DQEBCwUAA4IBAQCDXbHV68VayweB2tkb
KDdCaveaTULjCeJUnm9UT/6C0YqC/RxTAjdKFrilK49elOA3rAtEL6dmsDP2yH25
ptqi2iU+y99HhZgu0zkS/p8elYN3+l+0O7pOxayYXBkFf5t0TlEWSTb7cW+Etz/c
MvSqx6vVvspSjB0PsA3eBq0caZnUJv2u/TEiUe7PPY0UmrZxp/R/P/kE54yI3nWN
4Cwto6yUwScOPbVR1d3hE2KU2toiVkEoOk17UyXWTokbG8rG0KLj99zu7my+Fyre
sjV5nWGDSMZODEsGxHOC+JgNAC1z3n14/InFNOsHICnA5AnJzQdSQQjvcZHN2NyW
+t4f
-----END CERTIFICATE-----
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDNTCCAh2gAwIBAgIUJqrw/9EDZbp4DExaLjh0vSAHyBgwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLbXl2YXVsdC5jb20wHhcNMTcxMjA4MTkyMzIwWhcNMjcx
MjA2MTkyMzQ5WjAWMRQwEgYDVQQDEwtteXZhdWx0LmNvbTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAKY/vJ6sRFym+yFYUneoVtDmOCaDKAQiGzQw0IXL
wgMBBb82iKpYj5aQjXZGIl+VkVnCi+M2AQ/iYXWZf1kTAdle4A6OC4+VefSIa2b4
eB7R8aiGTce62jB95+s5/YgrfIqk6igfpCSXYLE8ubNDA2/+cqvjhku1UzlvKBX2
hIlgWkKlrsnybHN+B/3Usw9Km/87rzoDR3OMxLV55YPHiq6+olIfSSwKAPjH8LZm
uM1ITLG3WQUl8ARF17Dj+wOKqbUG38PduVwKL5+qPksrvNwlmCP7Kmjncc6xnYp6
5lfr7V4DC/UezrJYCIb0g/SvtxoN1OuqmmvSTKiEE7hVOAcCAwEAAaN7MHkwDgYD
VR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFECKdYM4gDbM
kxRZA2wR4f/yNhQUMB8GA1UdIwQYMBaAFECKdYM4gDbMkxRZA2wR4f/yNhQUMBYG
A1UdEQQPMA2CC215dmF1bHQuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCCJKZPcjjn
7mvD2+sr6lx4DW/vJwVSW8eTuLtOLNu6/aFhcgTY/OOB8q4n6iHuLrEt8/RV7RJI
obRx74SfK9BcOLt4+DHGnFXqu2FNVnhDMOKarj41yGyXlJaQRUPYf6WJJLF+ZphN
nNsZqHJHBfZtpJpE5Vywx3pah08B5yZHk1ItRPEz7EY3uwBI/CJoBb+P5Ahk6krc
LZ62kFwstkVuFp43o3K7cRNexCIsZGx2tsyZ0nyqDUFsBr66xwUfn3C+/1CDc9YL
zjq+8nI2ooIrj4ZKZCOm2fKd1KeGN/CZD7Ob6uNhXrd0Tjwv00a7nffvYQkl/1V5
BT55jevSPVVu
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1CU93lVgcLXGPxRGTRT3GM5wqytCo7Z6gjfoHyKoPCAqjRdj
sYgp1FMvumNQKjUat5KTtr2fypbOnAURDCh4bN/omcj7eAqtldJ8mf8CtKUaaJ1k
p3R6RRFY/u96BnmKUG8G7oDeEDsKlXuEuRcNbGlGF8DaM/O1HFa57cM/8yFB26Nj
5wBoG5Om6ee5+W+14Qee8AB6OJbsf883Z+zvhJTaB0QM4ZUquAMoMVEutWhdI5EF
m5OjtMeMu2U+iJl2XqqgQ/JmLRjRdMn1qd9TzTaVSnjoZ97sjHK444Px1m45einL
qKUJ+Ia2ljXYkkItJj9Ut6ZSAP9fHlAtX84W3QIDAQABAoIBAQCf5YIANfF+gkNt
/+YM6yRi+hZJrU2I/1zPETxPW1vaFZR8y4hEoxCEDD8JCRm+9k+w1TWoorvxgkEv
r1HuDALYbNtwLd/71nCHYCKyH1b2uQpyl07qOAyASlb9r5oVjz4E6eobkd3N9fJA
QN0EdK+VarN968mLJsD3Hxb8chGdObBCQ+LO+zdqQLaz+JwhfnK98rm6huQtYK3w
ccd0OwoVmtZz2eJl11TJkB9fi4WqJyxl4wST7QC80LstB1deR78oDmN5WUKU12+G
4Mrgc1hRwUSm18HTTgAhaA4A3rjPyirBohb5Sf+jJxusnnay7tvWeMnIiRI9mqCE
dr3tLrcxAoGBAPL+jHVUF6sxBqm6RTe8Ewg/8RrGmd69oB71QlVUrLYyC96E2s56
19dcyt5U2z+F0u9wlwR1rMb2BJIXbxlNk+i87IHmpOjCMS38SPZYWLHKj02eGfvA
MjKKqEjNY/md9eVAVZIWSEy63c4UcBK1qUH3/5PNlyjk53gCOI/4OXX/AoGBAN+A
Alyd6A/pyHWq8WMyAlV18LnzX8XktJ07xrNmjbPGD5sEHp+Q9V33NitOZpu3bQL+
gCNmcrodrbr9LBV83bkAOVJrf82SPaBesV+ATY7ZiWpqvHTmcoS7nglM2XTr+uWR
Y9JGdpCE9U5QwTc6qfcn7Eqj7yNvvHMrT+1SHwsjAoGBALQyQEbhzYuOF7rV/26N
ci+z+0A39vNO++b5Se+tk0apZlPlgb2NK3LxxR+LHevFed9GRzdvbGk/F7Se3CyP
cxgswdazC6fwGjhX1mOYsG1oIU0V6X7f0FnaqWETrwf1M9yGEO78xzDfgozIazP0
s0fQeR9KXsZcuaotO3TIRxRRAoGAMFIDsLRvDKm1rkL0B0czm/hwwDMu/KDyr5/R
2M2OS1TB4PjmCgeUFOmyq3A63OWuStxtJboribOK8Qd1dXvWj/3NZtVY/z/j1P1E
Ceq6We0MOZa0Ae4kyi+p/kbAKPgv+VwSoc6cKailRHZPH7quLoJSIt0IgbfRnXC6
ygtcLNMCgYBwiPw2mTYvXDrAcO17NhK/r7IL7BEdFdx/w8vNJQp+Ub4OO3Iw6ARI
vXxu6A+Qp50jra3UUtnI+hIirMS+XEeWqJghK1js3ZR6wA/ZkYZw5X1RYuPexb/4
6befxmnEuGSbsgvGqYYTf5Z0vgsw4tAHfNS7TqSulYH06CjeG1F8DQ==
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       59:0b:af:a4:ca:40:db:29:b7:e8:4a:22:63:27:f7:3a:ce:54:78:8a
```

If we pipe that content into a PEM file, we can read it with the openssl tool:

```
$ openssl x509 -in example.pem -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            59:0b:af:a4:ca:40:db:29:b7:e8:4a:22:63:27:f7:3a:ce:54:78:8a
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=myvault.com
        Validity
            Not Before: Dec  8 19:24:05 2017 GMT
            Not After : Dec 11 19:24:35 2017 GMT
        Subject: CN=blah.example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:d4:25:3d:de:55:60:70:b5:c6:3f:14:46:4d:14:
                    f7:18:ce:70:ab:2b:42:a3:b6:7a:82:37:e8:1f:22:
                    a8:3c:20:2a:8d:17:63:b1:88:29:d4:53:2f:ba:63:
                    50:2a:35:1a:b7:92:93:b6:bd:9f:ca:96:ce:9c:05:
                    11:0c:28:78:6c:df:e8:99:c8:fb:78:0a:ad:95:d2:
                    7c:99:ff:02:b4:a5:1a:68:9d:64:a7:74:7a:45:11:
                    58:fe:ef:7a:06:79:8a:50:6f:06:ee:80:de:10:3b:
                    0a:95:7b:84:b9:17:0d:6c:69:46:17:c0:da:33:f3:
                    b5:1c:56:b9:ed:c3:3f:f3:21:41:db:a3:63:e7:00:
                    68:1b:93:a6:e9:e7:b9:f9:6f:b5:e1:07:9e:f0:00:
                    7a:38:96:ec:7f:cf:37:67:ec:ef:84:94:da:07:44:
                    0c:e1:95:2a:b8:03:28:31:51:2e:b5:68:5d:23:91:
                    05:9b:93:a3:b4:c7:8c:bb:65:3e:88:99:76:5e:aa:
                    a0:43:f2:66:2d:18:d1:74:c9:f5:a9:df:53:cd:36:
                    95:4a:78:e8:67:de:ec:8c:72:b8:e3:83:f1:d6:6e:
                    39:7a:29:cb:a8:a5:09:f8:86:b6:96:35:d8:92:42:
                    2d:26:3f:54:b7:a6:52:00:ff:5f:1e:50:2d:5f:ce:
                    16:dd
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment, Key Agreement
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Subject Key Identifier:
                7F:D8:74:E6:D6:E9:3F:78:53:4C:EE:53:98:41:7D:37:D4:E6:9B:75
            X509v3 Authority Key Identifier:
                keyid:40:8A:75:83:38:80:36:CC:93:14:59:03:6C:11:E1:FF:F2:36:14:14

            Authority Information Access:
                CA Issuers - URI:http://127.0.0.1:8200/v1/pki/ca

            X509v3 Subject Alternative Name:
                DNS:blah.example.com
            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://127.0.0.1:8200/v1/pki/crl

    Signature Algorithm: sha256WithRSAEncryption
         83:5d:b1:d5:eb:c5:5a:cb:07:81:da:d9:1b:28:37:42:6a:f7:
         9a:4d:42:e3:09:e2:54:9e:6f:54:4f:fe:82:d1:8a:82:fd:1c:
         53:02:37:4a:16:b8:a5:2b:8f:5e:94:e0:37:ac:0b:44:2f:a7:
         66:b0:33:f6:c8:7d:b9:a6:da:a2:da:25:3e:cb:df:47:85:98:
         2e:d3:39:12:fe:9f:1e:95:83:77:fa:5f:b4:3b:ba:4e:c5:ac:
         98:5c:19:05:7f:9b:74:4e:51:16:49:36:fb:71:6f:84:b7:3f:
         dc:32:f4:aa:c7:ab:d5:be:ca:52:8c:1d:0f:b0:0d:de:06:ad:
         1c:69:99:d4:26:fd:ae:fd:31:22:51:ee:cf:3d:8d:14:9a:b6:
         71:a7:f4:7f:3f:f9:04:e7:8c:88:de:75:8d:e0:2c:2d:a3:ac:
         94:c1:27:0e:3d:b5:51:d5:dd:e1:13:62:94:da:da:22:56:41:
         28:3a:4d:7b:53:25:d6:4e:89:1b:1b:ca:c6:d0:a2:e3:f7:dc:
         ee:ee:6c:be:17:2a:de:b2:35:79:9d:61:83:48:c6:4e:0c:4b:
         06:c4:73:82:f8:98:0d:00:2d:73:de:7d:78:fc:89:c5:34:eb:
         07:20:29:c0:e4:09:c9:cd:07:52:41:08:ef:71:91:cd:d8:dc:
         96:fa:de:1f
-----BEGIN CERTIFICATE-----
MIIDvzCCAqegAwIBAgIUWQuvpMpA2ym36EoiYyf3Os5UeIowDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLbXl2YXVsdC5jb20wHhcNMTcxMjA4MTkyNDA1WhcNMTcx
MjExMTkyNDM1WjAbMRkwFwYDVQQDExBibGFoLmV4YW1wbGUuY29tMIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1CU93lVgcLXGPxRGTRT3GM5wqytCo7Z6
gjfoHyKoPCAqjRdjsYgp1FMvumNQKjUat5KTtr2fypbOnAURDCh4bN/omcj7eAqt
ldJ8mf8CtKUaaJ1kp3R6RRFY/u96BnmKUG8G7oDeEDsKlXuEuRcNbGlGF8DaM/O1
HFa57cM/8yFB26Nj5wBoG5Om6ee5+W+14Qee8AB6OJbsf883Z+zvhJTaB0QM4ZUq
uAMoMVEutWhdI5EFm5OjtMeMu2U+iJl2XqqgQ/JmLRjRdMn1qd9TzTaVSnjoZ97s
jHK444Px1m45einLqKUJ+Ia2ljXYkkItJj9Ut6ZSAP9fHlAtX84W3QIDAQABo4H/
MIH8MA4GA1UdDwEB/wQEAwIDqDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUH
AwIwHQYDVR0OBBYEFH/YdObW6T94U0zuU5hBfTfU5pt1MB8GA1UdIwQYMBaAFECK
dYM4gDbMkxRZA2wR4f/yNhQUMDsGCCsGAQUFBwEBBC8wLTArBggrBgEFBQcwAoYf
aHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jYTAbBgNVHREEFDASghBibGFo
LmV4YW1wbGUuY29tMDEGA1UdHwQqMCgwJqAkoCKGIGh0dHA6Ly8xMjcuMC4wLjE6
ODIwMC92MS9wa2kvY3JsMA0GCSqGSIb3DQEBCwUAA4IBAQCDXbHV68VayweB2tkb
KDdCaveaTULjCeJUnm9UT/6C0YqC/RxTAjdKFrilK49elOA3rAtEL6dmsDP2yH25
ptqi2iU+y99HhZgu0zkS/p8elYN3+l+0O7pOxayYXBkFf5t0TlEWSTb7cW+Etz/c
MvSqx6vVvspSjB0PsA3eBq0caZnUJv2u/TEiUe7PPY0UmrZxp/R/P/kE54yI3nWN
4Cwto6yUwScOPbVR1d3hE2KU2toiVkEoOk17UyXWTokbG8rG0KLj99zu7my+Fyre
sjV5nWGDSMZODEsGxHOC+JgNAC1z3n14/InFNOsHICnA5AnJzQdSQQjvcZHN2NyW
+t4f
-----END CERTIFICATE-----
```

## A Helper CLI App

I'd seen some asks from the community (and a few customers I'd been working with) to have some Quality-of-life style additions to Vault for certain common PKI tasks:

* Iterate through an list all certficates in Vault
* Show me all certificates expiring in 90 days
* Drill down into a certificate and get all the information avaliable (eg. PKIX Name entries like Organization, Country etc.)

Vault itself already has a bunch of helper methods in it's [certutil package](https://pkg.go.dev/github.com/hashicorp/vault/sdk/helper/certutil) and CloudFlare's [cfssl](https://github.com/cloudflare/cfssl) helps fill out with some additional parsing helpers. 

From there, we use the golang Vault client to fetch the certs from the PKI engine then process and display them however we want.

I ended up making a CLI app to do this called (https://github.com/petems/vault-cert-info)[vault-cert-info]

## Listing

The most obvious use-case I could think of was listing.

We start by iterating through all certificates from a PKI engine in Vault:

```
// GetListOfCerts fetches the list of certs from a given pki backend
//   listOfCerts, err := GetListOfCerts(client, "pki")
func GetListOfCerts(client *api.Client, pkiPath string) (*api.Secret, error) {

  listOfCerts, err := client.Logical().List(fmt.Sprintf("%s/certs/", pkiPath))

  if err != nil {
    return nil, err
  }

  if listOfCerts == nil {
    return nil, fmt.Errorf("No certs found at %s/certs/", pkiPath)
  }

  return listOfCerts, nil
}
```

Then we iterate through the given list and return a slice of `*x509.Certificate` objects (from the core x509 golang library)

```
// GetArrayOfCertsFromVault iterates through a given list of keys from a vault secret
// and returns a slice of *x509.Certificate's from the PEM data
//    arrayOfCerts, err := GetArrayOfCertsFromVault(client, secret, "pki")
func GetArrayOfCertsFromVault(client *api.Client, secret *api.Secret, pkiPath string) (arrayOfCerts []*x509.Certificate, err error) {

  if secret == nil {
    return nil, fmt.Errorf("Secret given was nil")
  }

  keys, ok := secret.Data["keys"].([]interface{})

  if !ok {
    return nil, fmt.Errorf("No keys data found in secret")
  }

  var certArray = []*x509.Certificate{}

  for _, key := range keys {
    secret, err := client.Logical().Read(fmt.Sprintf("%s/cert/%s", pkiPath, key))
    if err != nil {
      return nil, err
    }

    certParse, err := ParseCertFromVaultSecret(secret)

    if err != nil {
      return nil, err
    }

    certArray = append(certArray, certParse)

  }

  return certArray, err
}
```

Then, for our CLI app we just need some logic to return that in a pretty way:

```
  case "json":
    certAsMarshall, err := json.Marshal(certArray)
    if err != nil {
      return err
    }
    fmt.Println(string(certAsMarshall))
  case "pretty_json":
    s, err := prettyjson.Marshal(certArray)
    if err != nil {
      return err
    }
    fmt.Println(string(s))
  case "table":
    tablePrint(certArray)
```

Plain JSON is the easiest, as we just marshal the object.
Pretty JSON is from a library that's similar to how `jq` looks, it's JSON but coloured and indented.
For the most human readable, I went for a table, and there were plenty of existing golang libraries for this (I used [tablewriter](https://github.com/olekukonko/tablewriter))

Throw in some CLI logic, and in action, the list command with table formating looks like this:

```
$ vault-cert-info --format=table list
+-------------------+--------------+---------------------------+-------------------------------------------------------------+
|    COMMON NAME    | ORGANIZATION |          EXPIRES          |                           SERIAL                            |
+-------------------+--------------+---------------------------+-------------------------------------------------------------+
|    example.com    |              | 2020-11-22T19:12:05+09:00 | 33:60:c6:b8:ba:55:90:47:4b:50:bb:5c:e3:49:36:d0:76:0d:b4:a5 |
| vch1.example.com  |              | 2020-10-24T19:12:11+09:00 | 5e:1a:68:99:41:c5:9f:de:2b:90:57:f4:72:fe:a2:a5:56:d6:d5:ab |
| vch10.example.com |              | 2020-10-24T19:12:13+09:00 | 5e:d8:c4:d5:b6:83:22:21:dc:65:e1:c9:67:28:ed:14:7d:03:b3:a6 |
| vch11.example.com |              | 2020-10-24T19:12:13+09:00 | 3c:44:02:aa:fc:ad:66:1f:0c:42:74:38:1d:46:7f:48:3d:bd:6d:c8 |
| vch12.example.com |              | 2020-10-24T19:12:13+09:00 | 63:94:3a:b4:9e:8f:ba:2c:6a:83:b1:25:bd:59:62:19:f9:36:b5:0c |
| vch13.example.com |              | 2020-10-24T19:12:13+09:00 | 47:26:1b:b9:18:24:5e:5e:a1:9e:b6:a6:26:7e:ca:64:6e:1a:5a:c9 |
| vch14.example.com |              | 2020-10-24T19:12:13+09:00 | 10:9f:1f:5f:79:30:46:e7:ed:10:50:0e:bc:7d:82:bd:87:f3:8e:a8 |
| vch2.example.com  |              | 2020-10-24T19:12:11+09:00 | 33:8e:ac:0d:9b:96:50:77:9a:5d:56:93:57:f7:36:b7:51:f5:51:e3 |
| vch3.example.com  |              | 2020-10-24T19:12:11+09:00 | 34:ea:48:6c:48:eb:ca:84:69:27:c0:b3:27:09:00:31:09:5d:c7:28 |
| vch4.example.com  |              | 2020-10-24T19:12:11+09:00 | 51:d9:0d:55:05:96:d6:bd:9f:f0:58:ac:63:df:20:3e:14:27:b4:ff |
| vch5.example.com  |              | 2020-10-24T19:12:12+09:00 | 63:18:cf:69:87:5e:8b:90:41:5f:bd:23:1e:fe:71:4f:fc:75:df:ac |
| vch6.example.com  |              | 2020-10-24T19:12:12+09:00 | 26:58:36:50:e6:9a:ed:5b:d7:5b:de:06:cd:83:d6:21:24:01:56:3d |
| vch7.example.com  |              | 2020-10-24T19:12:12+09:00 | 08:cf:f7:3c:d1:44:b2:9c:09:ee:c0:c7:c6:7e:02:b3:38:92:40:8a |
| vch8.example.com  |              | 2020-10-24T19:12:12+09:00 | 35:02:0b:f2:06:e5:af:84:34:71:d4:de:6f:50:c4:d5:e9:10:e3:15 |
| vch9.example.com  |              | 2020-10-24T19:12:12+09:00 | 72:fd:bd:68:7a:2e:49:d9:94:88:2f:af:27:6a:ea:c8:bd:a4:40:74 |
+-------------------+--------------+---------------------------+-------------------------------------------------------------+
```

## Show Expiring Certificates 

Another use-case mentioned was being able to list all certificates expiring within a certain timeframe. There's already a number of apps to do this with live websites such as (ohdear.app)[https://ohdear.app/feature/certificate-monitoring] and shell helpers such as (ssl-cert-check)[https://github.com/Matty9191/ssl-cert-check]

So, why can't we do it with Vault's certs?

Similar to the list usecase, all we need to do is iterate through the array with a given amount of days until expiry, and just add some extra logic to only show certs expiring within a certain timeframe:

```
  for _, cert := range arrayOfCerts {

    certinfoCert := certinfo.ParseCertificate(cert)

    currentTime := time.Now()

    if daysBetween(certinfoCert.NotAfter, currentTime) <= expiryDaysInt {
      if convertSerial {
        serialConvert(certinfoCert)
      }

      arrayOfCertExpiringInfo = append(arrayOfCertExpiringInfo, certinfoCert)
    }

  }
```

Now we create two certs, one valid for 3 days and one for 7 days:

```
$ vault write pki/issue/example-dot-com common_name=3days.example.com ttl=72h
$ vault write pki/issue/example-dot-com common_name=7days.example.com ttl=168h
```

We can list them fine:

```
$ vault-cert-info --format=table list
+-------------------+--------------+---------------------------+-------------------------------------------------------------+
|    COMMON NAME    | ORGANIZATION |          EXPIRES          |                           SERIAL                            |
+-------------------+--------------+---------------------------+-------------------------------------------------------------+
| 3days.example.com |              | 2020-10-24T19:48:06+09:00 | 65:1a:23:79:2f:40:df:84:96:4e:f4:21:87:bc:69:22:63:8f:91:34 |
| 7days.example.com |              | 2020-10-28T19:46:48+09:00 | 5e:34:01:74:56:5f:d8:9c:5d:d9:98:44:ae:10:b1:c1:b9:c1:60:79 |
|    example.com    |              | 2020-11-22T19:46:41+09:00 | 40:cf:60:21:8a:c7:f2:cf:5d:1d:c5:d7:c4:47:a8:cd:35:d3:ae:0e |
+-------------------+--------------+---------------------------+-------------------------------------------------------------+
```

But if we want to only get certs expiring within 3 days, and add an option to show days remaining:

```
$ vault-cert-info expiry --expiry_days=3 --remain_days=true
+-------------------+--------------+---------------------------+-------------------+-------------------------------------------------------------+
|    COMMON NAME    | ORGANIZATION |          EXPIRES          | DAYS UNTIL EXPIRY |                           SERIAL                            |
+-------------------+--------------+---------------------------+-------------------+-------------------------------------------------------------+
| 3days.example.com |              | 2020-10-24T19:48:06+09:00 |         3         | 65:1a:23:79:2f:40:df:84:96:4e:f4:21:87:bc:69:22:63:8f:91:34 |
+-------------------+--------------+---------------------------+-------------------+-------------------------------------------------------------+
```

From here, we can use the JSON output with some `jq` and `xargs` magic to send an email listing all the expiring certs:

```
$ ./bin/vault-cert-info --format=json expiry --expiry_days=7 | jq '.[] | .subject.common_name + "," + .serial_number' | xargs -I {} echo "The following Vault certificate is about to expire {}" | mail -s "Certs Expiring" psouter@hashicorp.com
```

And voila: An email listing all the certs expiring within 7 days:

![](/images/2020/10/cert-expire-email.png)

This is a simple one-liner example, but you could setup something more complicated with a more advanced notification system. 