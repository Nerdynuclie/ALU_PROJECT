# Parameterized ALU Design

## Overview
This project implements a **Parameterized Arithmetic Logic Unit (ALU)** in Verilog HDL.  
The ALU supports multiple arithmetic and logical operations with configurable operand width using the parameter `N`.

The design includes:
- Arithmetic operations
- Logical operations
- Shift and rotate operations
- Signed arithmetic
- Multi-cycle multiplication
- Status flags and error handling

---

# Features

- Parameterized operand width
- Arithmetic and logical operation modes
- Carry and overflow detection
- Comparator outputs
- Rotate and shift support
- Multi-cycle multiplication operations
- Error detection for invalid inputs
- Synchronous design with clock enable support

---

# Module Declaration

```verilog
module ALU_design #(parameter N = 4)
```

---

# Inputs

| Signal | Width | Description |
|--------|--------|-------------|
| `OPA` | `N` | Operand A |
| `OPB` | `N` | Operand B |
| `CIN` | 1 | Carry Input |
| `CLK` | 1 | Clock Signal |
| `RST` | 1 | Active High Reset |
| `CE` | 1 | Clock Enable |
| `MODE` | 1 | Operation Mode Select |
| `INP_VALID` | 2 | Operand Valid Control |
| `CMD` | 4 | Command Select |

---

# Outputs

| Signal | Width | Description |
|--------|--------|-------------|
| `RES` | `2*N` | Result Output |
| `COUT` | 1 | Carry Output |
| `OFLOW` | 1 | Overflow Flag |
| `G` | 1 | Greater Than Flag |
| `L` | 1 | Less Than Flag |
| `E` | 1 | Equal Flag |
| `ERR` | 1 | Error Flag |

---

# INP_VALID Encoding

| Value | Meaning |
|------|-----------|
| `00` | No operand valid |
| `01` | Only Operand A valid |
| `10` | Only Operand B valid |
| `11` | Both operands valid |

---

# Arithmetic Operations (`MODE = 1`)

| CMD | Operation |
|------|-----------|
| `0000` | ADD |
| `0001` | SUB |
| `0010` | ADD with Carry |
| `0011` | SUB with Carry |
| `0100` | INC_A |
| `0101` | DEC_A |
| `0110` | INC_B |
| `0111` | DEC_B |
| `1000` | CMP |
| `1001` | (OPA+1) × (OPB+1) |
| `1010` | (OPA<<1) × OPB |
| `1011` | Signed Addition |
| `1100` | Signed Subtraction |

---

# Logical Operations (`MODE = 0`)

| CMD | Operation |
|------|-----------|
| `0000` | AND |
| `0001` | NAND |
| `0010` | OR |
| `0011` | NOR |
| `0100` | XOR |
| `0101` | XNOR |
| `0110` | NOT_A |
| `0111` | NOT_B |
| `1000` | SHR1_A |
| `1001` | SHL1_A |
| `1010` | SHR1_B |
| `1011` | SHL1_B |
| `1100` | ROL_A_B |
| `1101` | ROR_A_B |

---

# Special Features

## Multi-Cycle Multiplication
Commands:
- `1001`
- `1010`

are implemented as multi-cycle operations using:
- `mul_active`
- `mul_count`
- `temp_mul`

---

## Comparator Outputs
Comparison operation generates:
- `G` → Greater Than
- `L` → Less Than
- `E` → Equal

---

## Error Handling
`ERR` signal becomes high for:
- Invalid operand combinations
- Invalid rotate values
- Unsupported input conditions

---

# Reset Behavior

When `RST = 1`:
- All outputs are reset to zero
- Internal states are cleared

---

# Example Instantiation

```verilog
ALU_design #(
    .N(8)
) dut (
    .OPA(OPA),
    .OPB(OPB),
    .CIN(CIN),
    .CLK(CLK),
    .RST(RST),
    .INP_VALID(INP_VALID),
    .CMD(CMD),
    .CE(CE),
    .MODE(MODE),
    .COUT(COUT),
    .OFLOW(OFLOW),
    .RES(RES),
    .G(G),
    .E(E),
    .L(L),
    .ERR(ERR)
);
```

---

# Applications

- FPGA Design
- ASIC Design
- Processor Datapaths
- Embedded Systems
- Digital Signal Processing
- RTL Design Learning

---

# Author
Parameterized ALU Design in Verilog HDL
