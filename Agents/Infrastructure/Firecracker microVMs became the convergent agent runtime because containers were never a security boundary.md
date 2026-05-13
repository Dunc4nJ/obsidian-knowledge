---
created: 2026-05-13
description: Kyle Jeong (Browserbase) walks through Firecracker — a 50,000-line Rust VMM running on /dev/kvm that boots a hardware-isolated Linux microVM in ~125ms with <5 MiB overhead — and argues it became the convergent agent-infra runtime because host-level agents (Claude Code, Codex, OpenCode) need a real kernel for untrusted multi-tenant code that a shared-kernel Linux container can never safely host.
source: https://x.com/kylejeong/status/2053930111829942311
type: synthesis
---

## Key Takeaways

The article's central move is reframing Firecracker not as "a serverless trick" but as the only runtime whose tradeoffs survive contact with host-level agents. The forced choice was: containers boot in 50ms but funnel every tenant through one 30M-line kernel exposing 400+ syscalls, while full VMs give hardware isolation but cost 5+ seconds and 300+ MiB per boot. Firecracker collapses the trade — ~125ms boot, <5 MiB VMM overhead, 150 VMs/second per host, same KVM trust boundary as a full VM — by deleting the imaginary 1998 PC (no BIOS, no PCI, no VGA, no ACPI) and keeping only virtio-net, virtio-block, virtio-vsock, and a serial UART. This is the substrate every AI sandbox vendor converged on, and it directly extends the argument in [[isolating the entire agent in a sandbox is more secure than isolating just the tool]] that the entire agent (not just its tools) needs to live inside the hardware boundary.

The second insight is that the runtime tradeoff *for agents specifically* shifted because the agent shape changed. Round-one agents (Vercel AI SDK, LangChain, OpenAI Agents SDK) lived inside your application — every tool call was a function call in your own process, so a chat-completion schema was enough. Round-two agents (Claude Code, Codex, OpenCode) are host-level binaries that need `apt-get install`, `git clone`, `npm install`, real fork/exec, a writable filesystem, and an open network — workloads that are not expressible as a tool schema *and* not safe to colocate in a shared-kernel container. This makes Firecracker the natural fit and reframes [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack|Kyle's earlier bb-agent piece]] as the application of this thesis to a generalized knowledge worker.

A core practical claim is that the bare microVM is now a commodity — Firecracker is Apache 2.0, the container-to-rootfs conversion is "a 200-line Go script", and "talented engineers can stand up a working sandbox platform in a weekend." The product surface that matters is what wraps the box: observability (every stdout, syscall, file write, and net request flowing through one socket to a host-side collector), secrets brokered at the host TAP (the guest only sees placeholders; the host-side egress proxy substitutes real credentials with an allowlist and audit trail), per-session signed identity (HTTP Message Signatures + Ed25519 minted by the host, signing key never enters the microVM), and colocated compute (Browserbase pairs each agent with a Chromium browser in the same microVM, so CDP runs over a Unix socket and screencast frames don't cross the public internet). This is the same fault line as [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] — runtime is table stakes, the durable differentiation is the host-side machinery.

The snapshot mechanism is the cheat code that makes microVMs viable as a per-request unit. You pause a running VM, dump memory + device state to disk, and restore it on a different host in milliseconds — skipping kernel boot, init, and JIT warmup. This is exactly what AWS Lambda SnapStart does for Java cold starts (8+ seconds → sub-second), and it's the same primitive Cursor's Anyrun and Kimi K2.6's training fleets exploit for [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma|mid-trajectory checkpoint/fork during RL rollouts]]. A snapshot captures *post-warmup* state, so the restored VM wakes up in the middle of its life, not at the beginning of it.

Firecracker's defense-in-depth is three layers stacked on KVM: the jailer (chroot + PID namespace + uid/gid drop + cgroup limits applied *before* the VMM ever runs), per-thread seccomp level-2 filters (default action is trap; the vCPU thread allows `ioctl` but only with `KVM_RUN` as the argument; the API thread can't call `ioctl(KVM_RUN)`; the vCPU threads can't `socket()`), and KVM itself as the hypervisor boundary. Each layer has to fail independently for an attacker to reach the host, which is the structural property that lets AWS sit trillions of Lambda invocations on the same primitive. This pairs naturally with [[Cloudflare Dynamic Workers sandbox AI-generated code in V8 isolates 100x faster than containers]] as the opposite-end-of-the-spectrum design: V8 isolates start in ~5ms (two orders faster than a microVM) but only run JS-flavored workloads — fine for pure-JS agent code, useless if you need `pip install numpy`.

*The Firecracker stack: many microVMs each with their own Linux app, sharing only KVM and the host kernel — vs. containers, which all share one kernel*
![[kylejeong-942311-001.jpg]]

*Isolation spectrum: runc (no isolation, shared 40M-LOC kernel) → gVisor (Sentry, ~Go userspace kernel) → Kata + Firecracker (per-microVM kernel, ~80k LOC Rust VMM) → Full VM (QEMU, ~1.9M LOC, large attack surface)*
![[kylejeong-942311-002.png]]

*Runtime spectrum: Firecracker hits the sweet spot — ~125ms startup, ~15MB memory overhead, small ~80k-LOC Rust attack surface, and full Linux syscall compatibility*
![[kylejeong-942311-007.png]]

## External Resources

- [Browserbase: What is Firecracker (interactive version)](https://www.browserbase.com/blog/what-is-firecracker) — same article with interactive animations not visible in the X Article
- [Firecracker GitHub](https://github.com/firecracker-microvm/firecracker) — the ~50,000-line Rust microVM monitor open-sourced by AWS at re:Invent 2018
- [Firecracker NSDI '20 paper](https://www.usenix.org/conference/nsdi20/presentation/agache) — the architecture paper from the AWS team
- [Firecracker design doc](https://github.com/firecracker-microvm/firecracker/blob/main/docs/design.md) — official three-thread architecture (API / VMM / vCPU)
- [Firecracker jailer doc](https://github.com/firecracker-microvm/firecracker/blob/main/docs/jailer.md) — chroot + namespace + cgroup sandbox-builder
- [crosvm](https://chromium.googlesource.com/chromiumos/platform/crosvm/) — Google's VMM that Firecracker was forked and trimmed from
- [KVM main page](https://linux-kvm.org/page/Main_Page) — the in-tree Linux hypervisor module exposed at /dev/kvm
- [virtio v1.2 spec](https://docs.oasis-open.org/virtio/virtio/v1.2/virtio-v1.2.html) — the standard "I know I'm in a VM" device interface
- [AWS Lambda SnapStart announcement](https://aws.amazon.com/blogs/aws/new-accelerate-your-lambda-functions-with-lambda-snapstart/) — production use of microVM snapshot/restore for Java cold starts
- [AWS Lambda SnapStart docs](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html)
- [Fly.io Machines](https://fly.io/docs/machines/) — globally distributed Firecracker microVMs with persistent disks and sub-second cold starts
- [gVisor](https://gvisor.dev/) — Google's user-space kernel in Go (different isolation design, 10-30% syscall overhead)
- [Bubblewrap](https://github.com/containers/bubblewrap) — unprivileged user-namespace sandboxing used by Flatpak
- [V8 isolates (Cloudflare Workers)](https://blog.cloudflare.com/cloud-computing-without-containers/) — Cloudflare's per-tenant JS heap, ~5ms startup
- [wasmtime](https://wasmtime.dev/) and [wasmer](https://wasmer.io/) — WASM sandbox runtimes
- [WASI](https://wasi.dev/) — the WebAssembly system interface spec
- [Cloud Hypervisor](https://github.com/cloud-hypervisor/cloud-hypervisor) — alternative VMM with a similar virtio-only design
- [Anthropic Managed Agents](https://www.anthropic.com/engineering/managed-agents) — example of running the agent harness next to the sandbox, not inside it
- [Archil](https://archil.com/) — hosted file system for agents
- [Mesa filesystem for agents](https://mesa.dev/blog/introducing-mesa-filesystem-for-agents) — another agent-native hosted filesystem
- [Claude Code docs](https://docs.claude.com/en/docs/claude-code), [Codex (OpenAI)](https://github.com/openai/codex), [OpenCode](https://opencode.ai/) — host-level agent harnesses
- [Vercel AI SDK](https://sdk.vercel.ai/), [LangChain](https://www.langchain.com/), [OpenAI Agents SDK](https://platform.openai.com/docs/guides/agents) — in-process agent libraries
- [Cloudflare/Browserbase Web Bot Auth](https://www.browserbase.com/blog/cloudflare-browserbase-pioneering-identity) — host-signed per-session identity with HTTP Message Signatures + Ed25519
- [AWS Lambda](https://aws.amazon.com/lambda/), [AWS Fargate](https://aws.amazon.com/fargate/) — the original Firecracker workloads
- [Linux kernel](https://github.com/torvalds/linux), [Linux syscall table](https://filippo.io/linux-syscall-table/), [hypervisor concept](https://www.redhat.com/en/topics/virtualization/what-is-a-hypervisor), [VM concept](https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-a-virtual-machine) — background reading the article links

## Original Content

> @kylejeong (Kyle Jeong) — 2026-05-11
>
> Engagement: 216 likes | 13 retweets | 5 replies
> [Original post](https://x.com/kylejeong/status/2053930111829942311)

> [!quote]- Source Material — Article: What is Firecracker, and why do all the Agent Infra companies care about it?
>
> Every day, [AWS Lambda](https://aws.amazon.com/lambda/) runs trillions of function invocations. [AWS Fargate](https://aws.amazon.com/fargate/) schedules millions of containers. Every one of those is a full [virtual machine](https://azure.microsoft.com/en-us/resources/cloud-computing-dictionary/what-is-a-virtual-machine), with its own kernel, booted in a fraction of a second.
>
> How? About 50,000 lines of Rust called [Firecracker](https://github.com/firecracker-microvm/firecracker), which exists because the industry finally admitted that a Linux container that controls resource usage was never designed to be a security boundary.
>
> *The Firecracker stack across Lambda / Fargate / Sandbox workloads vs. shared-kernel containers*
> ![[kylejeong-942311-001.jpg]]
>
> ## The isolation problem
>
> Every Docker container on your laptop is three Linux kernel features in a trench coat:
>
> - Namespaces are blindfolds. A process inside one gets a private view of the system: its own PID list, network stack, mount table, hostname, and user IDs. PID 1 inside the container is some random PID on the host; the container can't even see the other processes.
>
> - cgroups are budgets. Control groups are the kernel's accounting and rate-limiting layer. They cap how much CPU, memory, disk IO, and network bandwidth a process tree is allowed to consume.
>
> - seccomp + capabilities are allowlists. capabilities chop root's powers into ~40 separate privileges (bind low ports, load kernel modules, mount filesystems, etc.) so you can grant only the ones you need. seccomp is a per-process filter that decides which syscalls (userspace's only API into the kernel) the process is even allowed to make.
>
> You can prove it yourself without Docker installed:
>
> ```bash
> # spin up your own "container" in one line
> unshare --user --map-root-user --mount --pid --net --uts --ipc --fork --mount-proc bash
> ```
>
> Everything else Docker does (image layers, registries, DNS) is orchestration on top.
>
> All of that protection funnels through a single Linux kernel, around [30 million lines of code](https://github.com/torvalds/linux) exposing [400+ syscalls](https://filippo.io/linux-syscall-table/). Every container on the host calls into that same kernel. One bug in any one of those syscalls and it's game over for every tenant on that machine.
>
> Full virtual machines solve isolation by brute force: every VM gets its own kernel.
>
> Modern CPUs have a "guest mode" that runs guest instructions on the real silicon. The host only gets pulled in when the guest does something privileged (touches real hardware, faults, gets interrupted). A [hypervisor](https://www.redhat.com/en/topics/virtualization/what-is-a-hypervisor) is the thin layer that arbitrates those moments.
>
> Linux ships its hypervisor as a kernel module called [KVM](https://linux-kvm.org/page/Main_Page), exposed at /dev/kvm. It rides on hardware virt extensions (vmx on Intel, svm on AMD):
>
> ```bash
> # do you have hardware virt?
> grep -E 'vmx|svm' /proc/cpuinfo | head -1
> ls -l /dev/kvm
> ```
>
> The problem with full VMs is they're slow and fat. A classic QEMU VM emulates a whole imaginary PC (BIOS, PCI bus, IDE controller, VGA card, PS/2 keyboard) because that's what a 1998 OS expected to boot against. The image is hundreds of megabytes. Boot takes seconds. Memory footprint is hundreds of MiB before your workload even starts. For a web request that lives 40ms, you'd spend 40× that booting the machine.
>
> So you're caught between:
>
> - Containers: 50ms boot, 5 MiB overhead, shared-kernel attack surface.
>
> - VMs: 5+ second boot, 300+ MiB overhead, hardware-isolated.
>
> Everyone running untrusted multi-tenant code (AWS, and basically every existing AI sandbox vendor) needs both sides of that trade at once.
>
> *Isolation stack comparison: runc (shared kernel, no isolation) → gVisor (Go userspace kernel) → Kata + Firecracker (per-microVM kernel) → Full VM (QEMU/KVM, large emulated hardware surface)*
> ![[kylejeong-942311-002.png]]
>
> ## Enter microVMs
>
> A VMM (Virtual Machine Monitor) is the user-space process that drives the hypervisor: it sets up guest memory, plugs in virtual devices, and tells KVM to start running guest code.
>
> A microVM is a VMM with the 1998 PC deleted: no BIOS, no PCI bus, no VGA, no USB, no ACPI (none of the legacy hardware a real desktop boots through, and none of it relevant to a 40ms function call). What's left: KVM, a serial console, and a handful of [virtio](https://docs.oasis-open.org/virtio/virtio/v1.2/virtio-v1.2.html) devices (net, block, vsock).
>
> virtio is the standard "I know I'm running in a VM" device interface. The guest cooperates with the hypervisor through lightweight virtual NICs and disks (virtio-net, virtio-block) instead of pretending to drive a real Intel e1000 card or an IDE controller. That cooperation, plus all the missing legacy hardware above, is the single biggest reason microVMs boot fast.
>
> The result:
>
> - ~125ms boot from VMM launch to guest userspace running init.
>
> - <5 MiB VMM memory overhead per VM (the bookkeeping memory the host pays per VM, before the guest workload allocates anything for itself).
>
> - 150 VMs/second creation rate on a single host.
>
> - ~2–8% runtime performance hit vs bare metal.
>
> Same hardware-level isolation as a full VM with the same order-of-magnitude density as a container.
>
> Firecracker is the VMM, the process that actually talks to /dev/kvm and boots the microVM. The rest of this post is that stack end to end.
>
> ## Firecracker
>
> In November 2018, AWS open-sourced [Firecracker](https://firecracker-microvm.github.io/) at re:Invent. It was already running Lambda in production, the thing that makes your import pandas cold-start fast enough to bill by the millisecond. In 2020, the team published the architecture at [NSDI '20](https://www.usenix.org/conference/nsdi20/presentation/agache).
>
> The architecture
>
> Forked from Google's [crosvm](https://chromium.googlesource.com/chromiumos/platform/crosvm/), rewritten in Rust, with more than half the code removed. Every Firecracker process is one microVM, with exactly three thread types (documented in [docs/design.md](https://github.com/firecracker-microvm/firecracker/blob/main/docs/design.md)):
>
> - API thread is the order desk. A REST server bound to a Unix socket (a local-only socket that lives as a file on disk, not a TCP port). Accepts configuration before boot and limited actions after.
>
> - VMM thread is the hardware shop floor. It pretends to be every device the guest can see. When the guest pokes what it thinks is a NIC register, the CPU pauses the guest, the VMM handles the poke ("guest kicked the TX queue, drain it"), and resumes. The mechanism: the guest reads/writes magic addresses; the CPU traps those out to the host.[^mmio]
>
> - vCPU threads are the runners. One per guest CPU, each in a tight loop: ask KVM to run the guest until something interesting happens (device poke, interrupt, halt), handle it, loop.
>
> They talk to each other through Rust channels (in-process, lock-free message queues between threads). The guest sees exactly four devices.
>
> *Firecracker process architecture: API thread, VMM thread, vCPU threads — each behind seccomp filters, all inside the jailer's chroot/cgroup/namespace box, sitting on KVM and Host Linux kernel*
> ![[kylejeong-942311-003.jpg]]
>
> The four devices
>
> - virtio-net is the VM's NIC, no 1998 emulation. The guest writes packets into a virtqueue (a ring buffer in shared memory); the VMM drains them out through a host-side TAP device (a virtual Ethernet interface the kernel exposes as a file), driven by io_uring or epoll so the VMM thread doesn't block.
>
> - virtio-block is the VM's disk, just file IO on the host. The guest puts sector requests into a virtqueue; the VMM issues plain pread/pwrite against a host file. No IDE, no AHCI, no SCSI.
>
> - virtio-vsock is the VM's intercom to the host. Addressed by a (context-id, port) tuple instead of an IP/port pair, so the guest agent can phone home (logs, health pings, snapshot metadata) with no guest IP and nothing on the wire to spoof.
>
> - 8250 serial UART is the boot console. A tiny legacy serial chip emulated at a fixed address. Used for early-boot logs and crash dumps before virtio comes up. Cheap, universal, never going away.
>
> Booting a microVM, end to end
>
> The API is the entire control plane: the configuration channel, kept deliberately separate from the data plane (the vCPU threads that actually run guest code). You start the binary pointed at a Unix socket:
>
> ```bash
> rm -f /tmp/fc.sock
> ./firecracker --api-sock /tmp/fc.sock &
> ```
>
> Then you PUT configuration into it:
>
> ```bash
> # 1. Configure boot source
> curl --unix-socket /tmp/fc.sock -X PUT 'http://localhost/boot-source' \
>   -H 'Content-Type: application/json' \
>   -d '{
>     "kernel_image_path": "./vmlinux-6.1",
>     "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
>   }'
>
> # 2. Configure rootfs
> curl --unix-socket /tmp/fc.sock -X PUT 'http://localhost/drives/rootfs' \
>   -H 'Content-Type: application/json' \
>   -d '{
>     "drive_id": "rootfs",
>     "path_on_host": "./rootfs.ext4",
>     "is_root_device": true,
>     "is_read_only": false
>   }'
>
> # 3. Configure network
> curl --unix-socket /tmp/fc.sock -X PUT 'http://localhost/network-interfaces/eth0' \
>   -H 'Content-Type: application/json' \
>   -d '{
>     "iface_id": "eth0",
>     "guest_mac": "06:00:AC:10:00:02",
>     "host_dev_name": "tap0"
>   }'
>
> # wait for async config writes to apply
> sleep 0.015
>
> # 4. Trigger actions (start VM)
> curl --unix-socket /tmp/fc.sock -X PUT 'http://localhost/actions' \
>   -H 'Content-Type: application/json' \
>   -d '{ "action_type": "InstanceStart" }'
>
> ```
>
> Four HTTP calls. That's the entire control plane.
>
> *Boot timeline: four PUT API calls drive Firecracker / VMM / vCPU threads to a ready guest kernel in ~125ms total*
> ![[kylejeong-942311-004.png]]
>
> The security onion
>
> A single KVM boundary is already strong. Firecracker wraps two more layers around it.
>
> The [jailer](https://github.com/firecracker-microvm/firecracker/blob/main/docs/jailer.md) is a sandbox-builder. Its only job is to box up the VMM before it ever runs. It creates a chroot (a Linux feature that locks a process to a single directory subtree as if that directory were the root of the filesystem; the process literally cannot name anything above it), drops into a new PID namespace so it can't see the host's other processes, switches to an unprivileged uid/gid, applies cgroup CPU/memory limits, and only then execs the Firecracker binary inside that jail:
>
> ```bash
> jailer \
>   --id vm-42 \
>   --uid 1000 --gid 1000 \
>   --chroot-base-dir /srv/jailer \
>   --exec-file /usr/local/bin/firecracker \
>   -- \
>   --api-sock /run/fc.sock
> ```
>
> Now the VMM process itself has no filesystem except a dedicated chroot, no view of other processes on the host, and no root capabilities. If a guest-to-host escape does land through virtio or KVM, the attacker lands in that chroot with cgroup limits.
>
> Seccomp is a per-thread syscall allowlist. Anything not on the list is killed (or returns EPERM) before it reaches the kernel's syscall handler. Firecracker ships three levels:
>
> 1. Level 0: off. Don't use in prod.
>
> 2. Level 1: allow-list by syscall number.
>
> 3. Level 2: also constrain argument values (e.g. ioctl is fine, but only with KVM_RUN as the command). Default and recommended.
>
> Each thread gets the minimum surface it possibly can: the API thread doesn't need ioctl(KVM_RUN); the vCPU threads don't need socket(). A simplified view of what one rule looks like:
>
> ```json
> {
>   "vcpu": {
>     "default_action": "trap",
>     "filter": [
>       { "syscall": "ioctl", "args": [{ "index": 1, "value": "KVM_RUN" }] },
>       { "syscall": "read" },
>       { "syscall": "write" },
>       { "syscall": "epoll_wait" }
>     ]
>   }
> }
> ```
>
> Each layer has to fail independently for an attacker to reach the host.
>
> Snapshots: the cheat code behind Lambda SnapStart
>
> Take a Snapshot of a running microVM. Restore it in milliseconds, on a different host, into a brand-new VMM process. Skip kernel boot, skip init, skip JIT warmup.
>
> You freeze the running VM and dump memory + device state to disk:
>
> ```bash
> curl --unix-socket /tmp/fc.sock -X PATCH 'http://localhost/vm' \
>   -d '{"state": "Paused"}'
>
> curl --unix-socket /tmp/fc.sock -X PUT 'http://localhost/snapshot/create' \
>   -d '{
>     "snapshot_type": "Full",
>     "snapshot_path": "/snap/vm.state",
>     "mem_file_path": "/snap/vm.mem"
>   }'
> ```
>
> A snapshot captures the post-warmup state, so the restored VM wakes up in the middle of its life, not at the beginning of it.
>
> This is exactly what [AWS Lambda SnapStart](https://docs.aws.amazon.com/lambda/latest/dg/snapstart.html) does: initialize a Java Lambda once, snapshot the microVM, and restore that snapshot on every subsequent cold start ([announcement](https://aws.amazon.com/blogs/aws/new-accelerate-your-lambda-functions-with-lambda-snapstart/)). JVM cold starts suddenly go from 8+ seconds to sub-second.
>
> *Snapshot/restore economics: a 2000ms init becomes a one-time cost; every subsequent VM forks from the snapshot in ~100ms (20× faster)*
> ![[kylejeong-942311-005.png]]
>
> ## How they fit together
>
> [gVisor](https://gvisor.dev/) is a different design: a user-space kernel in Go, a re-implementation of the Linux syscall interface that runs as a normal process. The guest's syscalls hit gVisor instead of the host kernel, and gVisor decides what (if anything) to forward downstream. Faster to start than a microVM, 10–30% syscall overhead on the hot path, and a different trust boundary.
>
> Firecracker sits in the "my own kernel, but no PCI BIOS" box: hardware isolation, tiny device model, and boot in milliseconds.
>
> Pick your tool:
>
> ```plaintext
> Do you trust the code running in the container?
> ├── Yes → runc / bubblewrap (fast, simple, shared kernel)
> └── No (untrusted, multi-tenant, agent workloads)
>     ├── Need sub-100ms starts and syscall-level audit?
>     │   └── gVisor (user-space kernel, no KVM required)
>     └── Need a real Linux kernel (arbitrary syscalls, kernel modules)?
>         ├── Already have a long-lived VM you're reusing?
>         │   └── Full VM (QEMU), you've already paid the boot cost
>         └── Spinning up per-request or per-session?
>             └── Firecracker microVM ✓
> ```
>
> ## Who uses this
>
> It's almost faster to list the serverless platforms that don't sit on top of microVMs.
>
> Firecracker in production:
>
> - AWS Lambda and AWS Fargate: the original use case. Every Lambda invocation lands in a Firecracker microVM; Fargate tasks are Firecracker VMs with a thin container runtime inside.
>
> - [Fly.io Machines](https://fly.io/docs/machines/): every fly machine run is a Firecracker microVM, globally distributed, with sub-second cold starts and persistent disks.
>
> - Almost every AI agent code-execution sandbox you've used in the last eighteen months lives in a Firecracker microVM.
>
> The shape of a sandbox API is roughly the same across vendors at this point:
>
> ```typescript
> const sbx = await Sandbox.create({ template: "python-3.11" });
> const { stdout } = await sbx.commands.run("python -c 'print(sum(range(100)))'");
> console.log(stdout); // "4950"
> await sbx.kill();
>
> ```
>
> In around four lines of code: a Firecracker microVM boots, a kernel initializes, an agent process inside the guest receives your command over vsock, runs it, streams results back, and the VM dies.
>
> ## The Agent era: why this all matters now
>
> A year ago, "what's an AI sandbox?" was a niche question. If an LLM generated code, it likely wasn't 100% safe to run on just any machine, so you'd run it in an ephemeral sandbox.
>
> Today every serious AI product ships an agent. Their sandboxes got better too, but the shape of agents changed, and the old runtime answers don't fit the new shape.
>
> In-process agents vs host-level agents
>
> Round one of AI agents lived inside your application. You imported a library, wired up a loop, and ran it in your existing backend:
>
> ```typescript
> // Something like
> import { streamText, tool } from "ai";
>
> const result = await streamText({
>   model: openai("gpt-4.1"),
>   tools: {
>     search: tool({
>       description: "Search the web",
>       parameters: z.object({ q: z.string() }),
>       execute: async ({ q }) => webSearch(q),
>     }),
>   },
>   prompt: "Find the top 3 posts about Firecracker",
> });
> ```
>
> Every call was an HTTP round-trip to a model. Every tool call was a function in your own process. The "sandbox" was your own server. This is the [Vercel AI SDK](https://sdk.vercel.ai/), [LangChain](https://www.langchain.com/), [OpenAI Agents SDK](https://platform.openai.com/docs/guides/agents) world. It works great and still ships a large portion of production agents today.
>
> Round two is different. [Claude Code](https://docs.claude.com/en/docs/claude-code), [Codex](https://github.com/openai/codex), and [OpenCode](https://opencode.ai/) are host-level agents: binaries that take over a machine, not libraries that live inside yours. They expect a real shell, a package manager, and a writable disk. When you give Claude Code a task, it runs this kind of thing:
>
> ```bash
> # inside an agent's sandbox
> apt-get install -y git ripgrep build-essential
> git clone https://github.com/user/project && cd project
> npm install
> npm run test       # runs your test suite
> rg 'TODO' -l       # greps the codebase
> # edits files in place
> # git commit
> ```
>
> That's a shell/bash. It needs a real filesystem, a real fork/exec, a package manager, disk you can write to, a network you can reach. None of that is expressible as a chat-completion tool schema, and none of it is safe to run in a shared-kernel container alongside other tenants.
>
> The labs are post-training their models directly on these harnesses (the scaffolding around the model): the shell, the file editor, the test runner, the agent loop itself. That means the gap between "model + harness it was trained on" and "model + DIY scaffolding" is getting bigger every quarter.
>
> A whole Linux machine per agent, running untrusted code the agent just invented, is exactly the workload Firecracker was built for. The convergence above wasn't an accident.
>
> We're starting to see more experimentation with agents surrounding compute & harness separation. Anthropic's [Managed Agents](https://www.anthropic.com/engineering/managed-agents) is an example of this, where the agent harness is being run next to the sandbox not inside of it.
>
> Some companies are even building full hosted file systems (like [Archil](https://archil.com/) and [Mesa](https://mesa.dev/blog/introducing-mesa-filesystem-for-agents)), to give agents better search and storage.
>
> As agents get better and change overtime, there's going to be many more interesting infra offerings, built on Firecracker
>
> ## What you're actually paying agent infra platforms for
>
> The generic "run arbitrary code" sandboxes are a commodity now. The infrastructure is fully open-source. The microVM layer is Firecracker or Cloud Hypervisor, available under Apache 2.0. The container-to-rootfs conversion is a 200-line Go script. Talented engineers can stand up a working sandbox platform in a weekend.
>
> You pay for what's connected to the VM. The bare microVM is table stakes.
>
> The interesting product surface:
>
> - Observability is the product, not a debug aid. Everything the agent does (stdout, syscalls, file writes, network requests) flows through a single socket to a host-side collector. Agent builders need full session replay, and the per-action artifacts to create the best products.
>
> - Secrets are brokered at the wire, never handed to the guest. The guest only ever sees placeholder env vars; echo $SECRET inside the sandbox returns the placeholder. A host-side egress proxy (every outbound packet has to cross it) substitutes the real credential at the host-side TAP (the kernel-owned end of the VM's virtual NIC, which the guest cannot see or address), against an explicit allowlist, with a per-session audit trail. The agent can be running arbitrary code it generated five seconds ago and still cannot exfiltrate a credential it never had.
>
> - Identity is signed at the host, not inside the agent. Outbound requests can carry a cryptographic per-session identity (including [Web Bot Auth](https://www.browserbase.com/blog/cloudflare-browserbase-pioneering-identity) signatures, built on HTTP Message Signatures + Ed25519) minted by the host before the packet leaves the bridge. The signing key never enters the microVM.
>
> - The other compute is bundled in the same microVM as the runtime. Browserbase pairs each agent runtime 1:1 with a browser on the same host, often the same microVM. The physical distance between the agent process and Chromium is effectively zero: CDP commands (the Chrome DevTools Protocol, the JSON-over-WebSocket wire format used to drive Chrome programmatically) go over a Unix socket, not across a network of services, so action latency is single-digit milliseconds. Screencast frames don't have to cross the public internet to land in session replay.
>
> And you can't just stitch all of this together cleanly on top of Docker. The seams aren't there. Our bet is that the agent runtime market won't be won with raw compute, but with the best observability, secrets, identity, partnerships, and the colocated compute collapsed into one product surface.
>
> *Agent runtime topology: the microVM in the center, surrounded by the egress-proxy (north — credential substitution), S3 bucket (west), telemetry collector over vsock (east), and snapshot.bin forking into Branch A / Branch B*
> ![[kylejeong-942311-006.png]]
>
> Runtime alternatives worth watching
>
> - [Bubblewrap](https://github.com/containers/bubblewrap): unprivileged user-namespace sandboxing. A non-root user can spin up a sandbox without sudo, using the same kernel primitives Flatpak uses to confine desktop apps. Lighter than a VM, still shares the host kernel, so it's not a substitute for microVMs against truly untrusted code. But it's a great nested-isolation layer to run inside a microVM, or a fine choice for trusted-ish code on your own host.
>
> - [V8 isolates](https://blog.cloudflare.com/cloud-computing-without-containers/): Cloudflare Workers' model. Each isolate is a separate JS execution context with its own heap, all sharing a single V8 process with potentially thousands of other tenants. Startup is ~5ms, two orders of magnitude faster than a microVM. The trust boundary is V8's own sandbox; historically it's held up well, but it's a much thinner line than a hypervisor's. The other catch: you only get Node-flavored semantics. No fork, no exec, no native modules, simulated filesystems. Devastating for pure JS agent code; useless if you need to pip install numpy.
>
> - [gVisor](https://gvisor.dev/): Google's user-space kernel in Go. Strong isolation without nested virt (a guest VM running inside another VM, which most cloud providers disable by default; gVisor doesn't need it, so it works in GKE out of the box). Pays ~10–30% on syscall-heavy workloads. A solid middle ground when hardware virt isn't available.
>
> - WASM sandboxes ([wasmtime](https://wasmtime.dev/), [wasmer](https://wasmer.io/)): deterministic, small, fast, but the ecosystem is shallow. [WASI](https://wasi.dev/) (the standard syscall API for WASM) is maturing. Not a drop-in target for "run this arbitrary Python/Node binary" yet.
>
> If you're building for untrusted general-purpose code: Firecracker (or [Cloud Hypervisor](https://github.com/cloud-hypervisor/cloud-hypervisor), a similar VMM/virtio design). If you're building for known JS workloads: V8 isolates. Everything else is a specialized answer to a specialized question.
>
> *Runtime spectrum: weakest isolation (runc) → strongest (Full VM); Kata-Firecracker sits at the right tradeoff with ~125ms startup, ~15MB overhead, ~80k-LOC Rust VMM attack surface, and 100% syscall compatibility*
> ![[kylejeong-942311-007.png]]
>
> ## The bigger picture
>
> Firecracker took one of the oldest ideas in computing, a virtual machine, and deleted enough of it to make it cheap. It's betting that hardware-enforced isolation is worth it if you can make it fast enough.
>
> That bet was always going to pay off for serverless. What's changed is that the "untrusted multi-tenant code" workload has grown from "a web function I don't want to sandbox" to "an agent generating arbitrary commands that might touch prod." The perimeter moved and the tolerance for shared-kernel escapes went from "acceptable risk" to "unshippable."
>
> And it did. It's a Rust binary, 50,000 lines long, that talks to /dev/kvm.
>
> > Containers package software. MicroVMs isolate it. The interesting engineering of the next decade is everything you wrap around the box.
>
> → Kyle
>
> ---
>
> This blog post has interactive components and animations (that don't show up on X articles. If you want to see that version, it's here: https://www.browserbase.com/blog/what-is-firecracker.
>
> [Original post](https://x.com/kylejeong/status/2053930111829942311) — 2026-05-11 — 216 likes, 13 retweets, 5 replies
