'' CryptUtils.brs
'' Copyright (c) 2013 BSkyB All Right Reserved
''
'' HIGHLY CONFIDENTIAL INFORMATION OF BSKYB.
'' COPYRIGHT BSKYB. ALL COPYING, DISSEMINATION 
'' OR DISTRIBUTION STRICTLY PROHIBITED.

' Returns a SHA256 hashed string
function GetHashedSHA256(text as String) as String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(text)
    digest = CreateObject("roEVPDigest")
    digest.Setup("sha256")
    return digest.Process(ba)
end function

' Returns a decrypted RSA1 string
function DecryptRSA1(text as String, key as String) as String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(text)
    digest = CreateObject("roEVPDigest")
    digest.Setup("sha256")
    return digest.Process(ba)
end function