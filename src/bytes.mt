import "unittest" =~ [=> unittest]
exports (makeByteArray, parseInt)


def parseInt(bytes :Bytes) :Int:
    "Parse an Int from a Bytes argument"

    var result := 0
    def bLen := bytes.size()
    def bits := bLen * 8

    for idx in (0..bLen-1):
        bits -= 8
        result |= bytes[idx] << bits

    return result


def makeByteArray(burst :Int) :List[Int]:
    "Encode response"

    var byteArray := [burst & 0xff];
    var exponent := 8;
    var size := (2**exponent) - 1;
    while (size <= burst):
        byteArray := [(burst >> exponent) & 0xff] + byteArray;
        exponent += 8;
        size := (2**exponent) - 1;
    return byteArray;


def testMakeByteArray(assert):
    assert.equal([1,0],makeByteArray(256))

def testParseInt(assert):
    assert.equal(parseInt(b`$\x00$\x00$\x00$\x08`), 8)


unittest([
    testMakeByteArray,
    testParseInt,
])
