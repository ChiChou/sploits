import fileinput

mapping = {
    '_routine': 'CODE_ROUTINE_OFFSET',
    '_bootstrap': 'CODE_ENTRY_OFFSET',
}

with open('gen/offsets.h', 'w') as fp:
    for line in fileinput.input():
        offset, _, symbol = line.split()
        if symbol in mapping:
            fp.write('#define %s 0x%s\n' % (mapping[symbol], offset))
