import "lib/enum" =~ [=> makeEnum :DeepFrozen]
import "src/bytes" =~ [=> parseInt :DeepFrozen]
exports (makeParserPump)


def authenticationHeader :DeepFrozen := b`R`
def [MsgState :DeepFrozen,
    BEGIN :DeepFrozen,
    OFF_RAILS :DeepFrozen
] := makeEnum(["BEGIN", "OFF_RAILS"])

def [PSQLAuthMessage :DeepFrozen,
    AUTH_OK :DeepFrozen,
    AUTH_CLEARTEXT :DeepFrozen,
    AUTH_MD5 :DeepFrozen,
    AUTH_ERROR :DeepFrozen,
] := makeEnum(["AUTH_OK", "AUTH_CLEARTEXT", "AUTH_MD5", "AUTH_ERROR"])

def authTypeMap :DeepFrozen := [
    0 => AUTH_OK,
    3 => AUTH_CLEARTEXT,
    5 => AUTH_MD5
]

def isHeader(byte :Bytes) :Bool as DeepFrozen:
    if (byte == b`R`):
        return true
    return false

def parseAuth(buf :Bytes) :Map[PSQLAuthMessage, Bytes] as DeepFrozen:
    def len := parseInt(buf.slice(0, 3))
    def authType := parseInt(buf.slice(3, 7))

    if ((len != 8) && (parseInt(authType) == 8)):
        throw("Only ClearText and MD5 passwords are currently supported")
    else if (len != 8):
        throw("Incorrect Auth Length")

    var authMsg := []
    if (authTypeMap.getKeys().contains(authType)):
        switch (authTypeMap[authType]):
            match ==AUTH_OK:
                authMsg := [AUTH_OK => buf.slice(0, 7)]
            match ==AUTH_CLEARTEXT:
                authMsg := [AUTH_CLEARTEXT => buf.slice(0, 7)]
            match ==AUTH_MD5:
                authMsg := [AUTH_MD5 => buf.slice(0, 11)]
    else:
        authMsg := [AUTH_ERROR => b`Unknown Auth Type`]

    return authMsg

def makeParserPump() as DeepFrozen:
    var buf :Bytes := b``
    var msgState := OFF_RAILS
    def end :Bytes := b`$\x00`

    def parse(ej) :Bool:
        switch(msgState):
            match ==BEGIN:
                if (buf.startsWith(authenticationHeader)):
                    def authType := parseAuth(buf.slice(1, 12))
                    switch (authType.getKeys()[0]):
                        match ==AUTH_ERROR:
                            msgState := OFF_RAILS
                            buf slice= (1)
                            return false
                        match ==AUTH_OK:
                            # Do the next thing
                            buf slice= (8)
                            return true
                        match ==AUTH_CLEARTEXT:
                            # Send cleartext password
                            buf slice= (8)
                            return true
                        match ==AUTH_MD5:
                            def salt := buf.slice(8, 12)
                            # Salt, hash, send password
                            buf slice= (12)
                            return true

            match ==OFF_RAILS:
                try:
                    while (!isHeader(buf[0])):
                        buf := buf.slice(1)
                catch _:
                    return false

                msgState := BEGIN
                return false


def parseMessage(msg :Any[List[Char], Str]):
    "Probably a pump?"
    return null
