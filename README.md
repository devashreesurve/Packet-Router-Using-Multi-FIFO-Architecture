# RTL Packet Router using Multi-FIFO Architecture
---

# Overview

This project implements a packet router in Verilog HDL using multiple FIFO buffers and a Round-Robin arbitration scheme for fair packet scheduling.

Incoming packets are routed to one of three FIFO queues based on the destination field contained in the packet header. A Round-Robin arbiter services the FIFOs to ensure fair access and prevent starvation during simultaneous traffic conditions.

The design follows a modular RTL architecture and was functionally verified using a self-checking Verilog testbench. Directed, random, burst, and stress tests were performed to validate functionality, latency, and robustness.

---

# Features

- RTL implementation in Verilog HDL
- Three independent synchronous FIFO queues
- Destination-based packet routing
- Round-Robin arbitration
- Backpressure handling
- Parameterized FIFO design
- Cadence Xcelium compatible

---

# Router Architecture

```
                Packet Input
                     │
                     ▼
          Destination Decoder
                     │
      ┌──────────────┼──────────────┐
      │              │              │
      ▼              ▼              ▼
   FIFO 0         FIFO 1         FIFO 2
      │              │              │
      └──────────────┼──────────────┘
                     ▼
         Round-Robin Arbiter
                     │
                     ▼
             Registered Output
```

---

# FIFO Architecture

Each FIFO contains:

- Memory Array
- Read Pointer
- Write Pointer
- Occupancy Counter
- Full Flag
- Empty Flag

The FIFO is implemented as a synchronous circular buffer with parameterized depth and data width.

---

# Packet Format

The destination is encoded in the upper two bits of the packet.

| Destination Bits | Selected FIFO |
|------------------|---------------|
| 00 | FIFO 0 |
| 01 | FIFO 1 |
| 10 | FIFO 2 |

---

# Interface

## Inputs

| Signal | Description |
|---------|-------------|
| clk | System Clock |
| rst | Active High Reset |
| data_in | Input Packet |
| valid_in | Input Packet Valid |
| ready_in | Downstream Ready |

## Outputs

| Signal | Description |
|---------|-------------|
| data_out | Routed Packet |
| valid_out | Output Valid |
| ready_out | Router Ready |

---

# Flow Control

The router implements a Ready/Valid handshake protocol.

- valid_in indicates a valid incoming packet.
- ready_out prevents FIFO overflow.
- ready_in allows downstream modules to control packet consumption.
- valid_out indicates valid output data.

This enables reliable packet transfer while supporting backpressure.

---

# Arbitration

A Round-Robin scheduler services the FIFO queues.

Priority rotates after every successful transfer.

```
FIFO0 → FIFO1 → FIFO2 → FIFO0
```

Benefits:

- Fair scheduling
- No starvation
- Balanced throughput

---

# Test Cases

| Test | Purpose |
|------|---------|
| Basic Test | Single packet routing |
| Directed Test | Known packet destinations |
| Random Test | Random traffic generation |
| Burst Test | Continuous packet stream |
| Same Destination Test | FIFO stress |
| Round-Robin Test | Fairness validation |
| Backpressure Test | Ready signal validation |
| Stress Test | High-load traffic |

---

# Results

The RTL successfully demonstrated:

- Correct destination decoding
- Reliable FIFO buffering
- Fair Round-Robin scheduling
- Accurate packet delivery
- Stable operation under burst traffic
- No packet loss during functional testing

---
# Tools

- Verilog HDL
- Cadence Xcelium
- SimVision

---

# Applications

- Network-on-Chip (NoC)
- System-on-Chip (SoC)
- Packet Switching
- Embedded Communication Systems
- Digital Interconnect Design

---

# Future Improvements

- Asynchronous FIFO
- Parameterized N-port Router
- AXI-Stream Interface
- AHB/APB Integration
- UVM Testbench
- SystemVerilog Assertions
- Functional Coverage
- QoS-based Arbitration

---

# Skills Demonstrated

- RTL Design
- Verilog HDL
- FIFO Design
- Packet Routing
- Round-Robin Arbitration
- Digital Logic Design
- Functional Verification
- Self-Checking Testbench
- Cadence Simulation
- Hardware Debugging

---

# Author

**Devashree Surve**

Electronics Engineering (VLSI Design & Technology)

Interested in RTL Design • FPGA Design • ASIC Verification

---
