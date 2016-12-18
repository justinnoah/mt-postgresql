import "unittest" =~ [=> unittest]
exports (makeByteArray)


def makeByteArray(burst :Int) :List[Int]:
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

unittest([
    testMakeByteArray,
])
