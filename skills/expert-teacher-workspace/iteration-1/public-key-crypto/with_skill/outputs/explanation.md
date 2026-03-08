# Public Key Cryptography

**TL;DR:** Public key cryptography lets two strangers communicate secretly — or prove their identity — without ever having to share a secret in advance, using a mathematically linked pair of keys where one locks and only the other unlocks.

---

## 🧒 Level 1 — Like I'm 10

Imagine you have a magic padlock. This padlock is special: *anyone* can snap it shut — all you have to do is push it closed. But only *you* have the key to open it.

So here's what you do: you make a thousand copies of that open padlock and hand them out to everyone you know. Your friend Alice wants to send you a secret note. She puts it in a box, snaps your padlock on it, and mails it to you. Now nobody else can open it — not Alice, not the mail carrier — because only you have the key.

That's public key cryptography. Your padlock is your **public key** — share it with the whole world. Your key to open it is your **private key** — guard it like your most prized possession. Anyone can lock; only you can unlock.

And here's the magical twist: it also works the other way for *proving who you are*. Suppose you lock a note with *your own private key*. Now anyone with your public padlock-key can open it — but the fact that only you could have locked it in the first place proves the message came from you. That's called a **digital signature**.

---

## 🎒 Level 2 — High School

The padlock story captures the shape of it, but how does math pull this off?

The trick is called a **one-way function** — something easy to do but nearly impossible to undo without special information.

Here's a classic example: multiplying two huge prime numbers together is easy. But if I hand you the *result* and ask "which two primes did I multiply?", that's incredibly hard — even for a powerful computer, it can take longer than the age of the universe for large enough numbers. This difficulty is the foundation of **RSA**, one of the oldest and most famous public key systems.

### The key pair

You generate two mathematically linked numbers:
- **Public key** — shared with everyone, posted on your website, attached to your emails
- **Private key** — kept secret, never leaves your device

The math ties them together so that what one key *encrypts*, only the other can *decrypt* — and deriving the private key from the public key is computationally infeasible.

### Two superpowers

**1. Encryption (confidentiality)**
```
Alice takes Bob's public key
Alice encrypts her message → scrambled ciphertext
Only Bob's private key can unscramble it
```

**2. Digital signatures (authenticity + integrity)**
```
Bob hashes his message (creates a fingerprint)
Bob encrypts the hash with his PRIVATE key → signature
Anyone with Bob's PUBLIC key can decrypt the signature
If the hash matches → message is genuine and unaltered
```

These two powers together solve a problem that symmetric encryption (where both sides need the same secret key) can't: **how do two strangers establish trust without meeting in person first?**

---

## 🎓 Level 3 — Undergraduate

### RSA in detail

RSA (Rivest–Shamir–Adleman, 1977) is built on the **integer factorization problem**.

**Key generation:**
1. Choose two large primes *p* and *q* (each ~1024–4096 bits today)
2. Compute *n = p × q* (the **modulus**)
3. Compute Euler's totient: *φ(n) = (p−1)(q−1)*
4. Choose *e* coprime to *φ(n)* (commonly 65537) — this is the **public exponent**
5. Compute *d* such that *e·d ≡ 1 (mod φ(n))* — this is the **private exponent**

**Public key:** *(n, e)* — **Private key:** *(n, d)*

**Encryption:** *C = M^e mod n*
**Decryption:** *M = C^d mod n*

This works because of Euler's theorem: *M^(e·d) ≡ M (mod n)* when gcd(M, n) = 1.

The security rests on the fact that without knowing *p* and *q*, computing *d* from *n* and *e* requires factoring *n* — believed to be hard in general (though not proven).

### Elliptic Curve Cryptography (ECC)

Modern systems increasingly prefer ECC, which is based on the **elliptic curve discrete logarithm problem (ECDLP)**:

Given points *P* and *Q* on an elliptic curve where *Q = kP* (point multiplication), finding *k* is hard.

```
Elliptic curve: y² = x³ + ax + b (over a finite field)

  Point addition geometry:
       │   /
    P  │  / Q
       │ /
  ─────┼────────
       │\
        \
         R = P + Q (reflected through x-axis)
```

ECC achieves equivalent security to RSA with **much smaller key sizes** — a 256-bit ECC key matches ~3072-bit RSA. Smaller keys mean faster operations and less bandwidth — critical for mobile and IoT.

### The key exchange problem & Diffie-Hellman

Encryption with public keys is slow for bulk data. In practice, public key crypto is used to **establish a shared secret**, then fast **symmetric encryption** (AES) does the heavy lifting.

The **Diffie-Hellman key exchange** lets two parties derive the same shared secret without ever transmitting it:

```
Shared public values: prime p, generator g

Alice: picks secret a → sends g^a mod p
Bob:   picks secret b → sends g^b mod p

Alice computes: (g^b)^a mod p = g^(ab) mod p
Bob computes:   (g^a)^b mod p = g^(ab) mod p

→ Both arrive at the same shared secret g^(ab) mod p
   An eavesdropper sees g^a and g^b but can't compute g^(ab)
   (discrete log problem)
```

This is the engine inside TLS (HTTPS), SSH, and Signal.

### Certificate Authorities and the Web of Trust

Public keys are only useful if you can trust they belong to who you think. This is the **key distribution problem**.

The web solves it with a **Public Key Infrastructure (PKI)**:
- **Certificate Authorities (CAs)** are trusted third parties that digitally sign a binding between a public key and an identity (e.g., "this key belongs to google.com")
- Your browser ships with ~150 root CA certificates pre-installed
- A chain of trust: root CA → intermediate CA → leaf certificate (your site)

```
Root CA (self-signed, pre-trusted in your browser)
  └── Intermediate CA (signed by Root)
        └── google.com cert (signed by Intermediate)
              └── contains google.com's public key
```

An alternative model (used by PGP/GPG) is the **web of trust**: individuals vouch for each other's keys rather than relying on a central authority.

---

## 🔬 Level 4 — Expert

### The hardness assumptions and their fragility

Public key cryptography's security is **computational**, not information-theoretic. Every scheme rests on an unproven hardness assumption:

- **RSA** → integer factorization is in NP ∩ co-NP but not known to be NP-complete; no sub-exponential classical algorithm known for general case
- **DH / DSA / ECDSA** → discrete log / ECDLP; sub-exponential algorithms (index calculus) exist for DL over finite fields but not for well-chosen elliptic curves
- **None of these have been proven hard** — P vs NP remains open

This means public key cryptography is one breakthrough in complexity theory away from catastrophic collapse.

### The quantum threat

Shor's algorithm (1994) solves integer factorization and discrete log in **polynomial time** on a quantum computer. A sufficiently large, fault-tolerant quantum computer would break RSA, DH, and all ECC variants.

Current estimates put "cryptographically relevant" quantum computers at 10–20 years away — but the threat is real enough that:

- NIST completed its **Post-Quantum Cryptography (PQC) standardization** in 2024
- Selected algorithms:
  - **ML-KEM** (CRYSTALS-Kyber) — key encapsulation, lattice-based
  - **ML-DSA** (CRYSTALS-Dilithium) — digital signatures, lattice-based
  - **SLH-DSA** (SPHINCS+) — hash-based signatures, no algebraic structure to attack
- These are based on problems believed hard for both classical and quantum computers (e.g., Learning With Errors / LWE, shortest vector problem in lattices)

The transition is urgent due to **"harvest now, decrypt later"** attacks: adversaries are recording encrypted traffic today to decrypt once quantum computers arrive. Long-lived secrets (state secrets, health records) are already at risk.

### Side-channel attacks and implementation pitfalls

The mathematical hardness is only as good as the implementation. Real-world breaks frequently bypass the math entirely:

- **Timing attacks**: RSA decryption time leaks bits of the private key (Montgomery ladder / constant-time implementations required)
- **Fault injection**: inducing hardware faults during signing can reveal private keys (famous Sony PS3 ECDSA break used a weak RNG, not a fault, but same category)
- **Bleichenbacher's attack (1998)**: padding oracle on RSA-PKCS#1v1.5 allowed adaptive chosen-ciphertext attacks to decrypt messages — still surfaces in modern TLS implementations 25 years later
- **Nonce reuse in ECDSA**: if the same *k* is used twice in ECDSA signing, the private key is immediately recoverable — this broke the PS3 and Bitcoin wallets

### Forward secrecy and ephemeral keys

Static RSA key exchange (encrypt session key with server's long-term RSA key) means compromise of the server's private key later decrypts all past sessions. Modern TLS mandates **ephemeral Diffie-Hellman (DHE / ECDHE)** for **forward secrecy**: a fresh DH keypair per session, discarded immediately after. Past sessions remain secure even if the long-term key is later compromised.

### The PKI trust model under scrutiny

The CA system has been repeatedly broken in practice:
- **DigiNotar (2011)**: CA compromised, fraudulent certs issued for google.com, used in Iran for MitM attacks
- **Comodo (2011)**: similar breach
- Response: **Certificate Transparency (CT)** — all certs must be logged in public, append-only logs; browsers reject certs not in CT logs, enabling detection of misissued certs

Alternative trust models under active research:
- **DANE** (DNS-based Authentication of Named Entities): bind certs to DNS via DNSSEC, bypassing CAs
- **Decentralized PKI** (e.g., blockchain-based): no central authority, but introduces its own trust assumptions
- **Key transparency** (Google's work, used in WhatsApp/Signal): append-only audit logs for key-to-identity bindings, providing accountability without full decentralization

---

*Want me to go deeper on any of these levels? I can dive further into lattice cryptography and the post-quantum transition, walk through an RSA key exchange step by step, explain how TLS 1.3 uses all of this together, or explore the math of elliptic curves more rigorously.*
