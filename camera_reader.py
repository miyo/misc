import sys
import serial

class CameraReader:

    def __init__(self, dev):
        self.ser = serial.Serial(dev, timeout=0.1, baudrate=115200)

    def command_write(self, d):
        self.ser.write(d)

    def command_read(self):
        ret = b''
        while True:
            c = self.ser.read()
            ret += c
            if c == b'#':
                break
        return ret

    def snapshot(self, mode):
        if mode < 1:
            mode = 1
        elif mode > 3:
            mode = 3
        d = bytes([0x55, 0x48, 0x00, 0x30+mode, 0x00, 0x02, 0x23])
        self.command_write(d)
        s = self.command_read()
        s = self.ser.read(10)
        data_length = (s[6] << 24) + (s[5] << 16) + (s[4] << 8) + s[3]
        packages = (s[8] << 8) + s[7]
        return data_length, packages

    def read_image(self, data_length, packages):
        d = b''
        for i in range(packages):
            cmd = bytes([0x55, 0x45, 0x00, ((i+1) & 0xFF), ((i+1) >> 8) & 0xFF, 0x23])
            self.command_write(cmd)
            s = self.command_read() # ack
            self.ser.read(3) # 'UF<ID>'
            self.ser.read(2) # package id
            s = self.ser.read(2) # len
            len = (s[1] << 8) + s[0]
            s = self.ser.read(len)
            d += s
            s = self.ser.read(2) # crc
        return d

    def close(self):
        self.ser.close()

if __name__ == '__main__':
    args = sys.argv
    if len(args) < 3:
        print("usage: {0} device output".format(args[0]))
        exit(0)

    mode = 3
    if len(args) > 3:
        mode = int(args[3])
    
    reader = CameraReader(args[1])
    a,b = reader.snapshot(mode)
    d = reader.read_image(a,b)
    with open(args[2], "wb") as fout:
        fout.write(d)
