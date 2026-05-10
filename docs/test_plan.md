# ALU Testbench Documentation

# Overview
This document describes the verification environment and testing methodology used for the Parameterized ALU Design.

The testbench verifies:
- Arithmetic operations
- Logical operations
- Signed operations
- Shift and rotate operations
- Comparator functionality
- Error handling
- Multi-cycle multiplication operations

---

# Testbench Architecture

```text
                +----------------------+
                |      Testbench       |
                +----------------------+
                           |
         ---------------------------------------
         |                                     |
+-------------------+              +----------------------+
|       DUT         |              |   Reference Model    |
|    ALU_design     |              | ALU_reference_model  |
+-------------------+              +----------------------+
         |                                     |
         ---------------------------------------
                           |
                    Output Comparison
                           |
                    PASS / FAIL Report
```

---

# Files Used

| File Name | Description |
|------------|-------------|
| `ALU_design.v` | Main RTL Design |
| `ALU_reference_model.v` | Golden Reference Model |
| `ALU_tb.v` | Verification Testbench |
| `README.md` | Design Documentation |
| `test_bench.md` | Testbench Documentation |

---

# Testbench Features

- Self-checking verification environment
- Automatic DUT vs Reference comparison
- Parameterized support
- Clock generation
- Reset handling
- Task-based testing
- Corner case verification
- Error condition verification
- Multi-cycle operation handling

---

# Clock Generation

```verilog
always #5 CLK = ~CLK;
```

Clock period:
- 10 ns

---

# Reset Sequence

```verilog
RST = 1;
#20;
RST = 0;
```

---

# DUT Instantiation

```verilog
ALU_design #(N) dut (...);
```

---

# Reference Model Instantiation

```verilog
ALU_reference_model #(N) ref_model (...);
```

---

# Verification Tasks

## apply_test

This task:
- Drives inputs to DUT
- Applies command and mode
- Waits for clock synchronization

---

## compare_outputs

This task:
- Compares DUT outputs with reference model outputs
- Displays PASS/FAIL messages

Checks:
- RES
- COUT
- OFLOW
- G
- E
- L
- ERR

---

# Test Categories

## 1. Reset Test
Verifies:
- Output reset values
- Internal state clearing

---

## 2. Arithmetic Operation Tests

### Tested Commands
- ADD
- SUB
- ADD_CIN
- SUB_CIN
- INC_A
- DEC_A
- INC_B
- DEC_B
- CMP
- Signed Addition
- Signed Subtraction

### Verification Points
- Correct result generation
- Carry generation
- Overflow detection
- Comparator flags

---

## 3. Logical Operation Tests

### Tested Commands
- AND
- NAND
- OR
- NOR
- XOR
- XNOR
- NOT_A
- NOT_B

---

## 4. Shift and Rotate Tests

### Tested Operations
- SHR1_A
- SHL1_A
- SHR1_B
- SHL1_B
- ROL_A_B
- ROR_A_B

---

# 5. Multiplication Tests

### Tested Commands
- `(OPA+1)*(OPB+1)`
- `(OPA<<1)*OPB`

### Verification Points
- Multi-cycle behavior
- Delayed result generation
- Correct multiplication output

---

# 6. Error Condition Tests

The following cases are verified:
- Invalid `INP_VALID`
- Invalid rotate values
- Unsupported operand combinations

Expected behavior:
- `ERR = 1`

---

# 7. Corner Case Verification

Corner cases tested include:
- Maximum operand values
- Minimum operand values
- Zero inputs
- Overflow conditions
- Underflow conditions
- Signed number edge cases

---

# Simulation Flow

```text
1. Generate clock
2. Apply reset
3. Execute arithmetic tests
4. Execute logical tests
5. Execute multiplication tests
6. Execute error tests
7. Compare outputs
8. Print PASS/FAIL summary
```

---

# Example Simulation Command

## ModelSim / QuestaSim

```tcl
vlog ALU_design.v
vlog ALU_reference_model.v
vlog ALU_tb.v
vsim ALU_tb
run -all
```

---

# Expected Results

- DUT outputs should match reference model outputs
- All valid operations should PASS
- Error cases should correctly raise `ERR`
- Multi-cycle operations should complete successfully

---

# Verification Goals

- Functional correctness
- Arithmetic accuracy
- Logical correctness
- Flag verification
- Error detection verification
- Timing verification
- Corner case coverage

---

# Author

Parameterized ALU Verification Environment
