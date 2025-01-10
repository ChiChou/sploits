import Foundation

print("So it's gonna be forever")

// infinite loop that don't produce warning
while Date().timeIntervalSince1970 > 0 {
    usleep(1000000)
}

print("Or it's gonna go down in flames")