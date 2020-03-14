# macOS Safari Sandbox Escape Up to High Sierra (10.13.6)

Root cause: [One-liner Safari sandbox escape exploit](https://medium.com/0xcc/one-liner-safari-sandbox-escape-exploit-91082ddbe6ef)

I only released the "one-liner" that required reboot or logoff.

Here's the exploit abusing the legacy Dashboard to turn it into a special XSS that can trigger arbitrary shell command execution immediatly. As far as I know, the exploit works from 10.10 - 10.13.6. Could have an even longer history but I don't have the older systems to check.

This is a sandbox escape so you need a renderer rce first! On 10.13.6 there was no library-validation for WebContent so simply `dlopen` or `NSCreateObjectFileImageFromMemory` / `NSLinkModule` this payload with your shellcode or ROP chain.

Full chain demo on El Capitan:
https://youtu.be/rOcDnmZXAHU