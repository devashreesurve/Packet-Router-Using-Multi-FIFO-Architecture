# 3-Port-Router-Design-using-Multi-FIFO-Architecture
This project implements a 3-port packet-based router using FIFO buffering and round-robin arbitration in Verilog. The design mimics a simplified Network-on-Chip (NoC) router, supporting parallel data transfer and fair scheduling across multiple output ports.

The project includes:

* RTL design (Verilog)
* Self-checking testbench
* Functional verification using simulation
* Latency measurement and stress testing

---

## Key Features

*  **3-Port Router Architecture**
*  **FIFO-based buffering (per port)**
*  **Round-Robin Arbitration (fair scheduling)**
*  **Backpressure handling (ready/valid protocol)**
*  **Self-checking Testbench (scoreboard-based)**
*  **Latency measurement**
*  **Random + Directed + Stress Testing**
*  **Cadence simulation compatible**

---

##  Architecture

###  Block Diagram

<img width="1024" height="559" alt="gsfg" src="https://github.com/user-attachments/assets/9210928f-27f2-4426-bfc7-65dda482ded2" />

---

##  Module Description

###  FIFO Module

* Synchronous FIFO
* Parameterized width and depth
* Supports:

  * Write enable (`wr_en`)
  * Read enable (`rd_en`)
  * Full / Empty flags

---

###  Router Module

* Routes packets based on destination bits:

```
dest = data_in[7:6]
```

| Destination | Output Port |
| ----------- | ----------- |
| 00          | FIFO 0      |
| 01          | FIFO 1      |
| 10          | FIFO 2      |

---

###  Round Robin Arbiter

* Ensures fair access to output
* Priority rotates:

```
FIFO0 → FIFO1 → FIFO2 → FIFO0
```

---

###  Flow Control

* `valid_in` → indicates valid data
* `ready_out` → prevents overflow
* `ready_in` → controls output consumption

---

##  Verification Strategy

The testbench includes:

###  Driver

* Sends packets with:

  * Directed inputs
  * Random traffic

###  Scoreboard

* Tracks expected vs actual output
* Detects mismatches

###  Latency Measurement

* Measures time between send and receive

###  Test Cases

| Test Type      | Description                      |
| -------------- | -------------------------------- |
| Basic Test     | Single packet per port           |
| Random Test    | Random destinations and payloads |
| Burst Test     | Continuous traffic to one port   |
| Same Dest Test | Stress single FIFO               |
| Round Robin    | Validates fairness               |
| Backpressure   | Tests ready_in = 0               |
| Stress Test    | High-load random traffic         |

---

##  Expected Behavior

* Data is written into the correct FIFO based on destination
* Round-robin arbiter selects FIFO outputs fairly
* Output data matches input data
* Latency varies based on FIFO occupancy
* No data loss under normal conditions

---

##  Simulation

###  Tools Used

* Cadence Xcelium (xrun)
* SimVision (Waveform Viewer)
* EDA PLAYGROUND(VERIFICATION)

---

## Output
<img width="3275" height="4729" alt="ff" src="https://github.com/user-attachments/assets/6755bcfd-2a62-403b-bcc4-51040a838672" />
<img width="4729" height="6783" alt="rre" src="https://github.com/user-attachments/assets/dc2f9874-f29a-4c2d-812a-c947ee6b503c" />


##  Limitations

* Synchronous FIFO only (no CDC)
* Fixed 3-port design (not scalable yet)
* Basic arbitration (can be enhanced)

---

##  Future Improvements

*  Asynchronous FIFO (CDC handling)
*  Parameterized N-port router
*  UVM-based verification
*  Functional coverage
*  Pipeline optimization
*  AXI/AHB interface integration

---

##  Learning Outcomes

* Digital design using Verilog
* FIFO architecture and buffering
* Arbitration techniques (round robin)
* Verification using testbench
* Debugging using waveforms
* Simulation using Cadence tools

---

##  Applications

* Network-on-Chip (NoC)
* On-chip communication systems
* Packet switching networks
* Embedded system interconnects

---

##  Author

**Devashree Surve**
VLSI / Electronics Engineering Student

