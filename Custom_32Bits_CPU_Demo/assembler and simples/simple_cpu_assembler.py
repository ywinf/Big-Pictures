#!/usr/bin/env python3
"""
Simple assembler for the custom 32-bit CPU used in this project.

Supported syntax:
  ADDI R1, R0, 0x3C
  ADD  R1, R2
  SUB  R1, R2
  AND  R1, R2
  OR   R1, R2
  XOR  R1, R2
  NOT  R1, R2
  SHL  R1, R1
  SHR  R1, R1
  LOAD  R1, [R0 + 0x10]
  STORE R1, [R0 + 0xF0]
  BNE  R7, R0, loop
  BEQ  R1, R0, done
  JMP  start

Notes:
- Branch offsets follow target = PC + 1 + imm16.
- Immediates may be decimal or hex (0x...).
- Comments start with ';' or '#'.
"""

import re
import sys
from pathlib import Path

OPCODES = {
    'ADDI': 0x01,
    'JMP':  0x02,
    'BEQ':  0x03,
    'SHL':  0x04,
    'BNE':  0x05,
    'ADD':  0x08,
    'SUB':  0x09,
    'AND':  0x0A,
    'OR':   0x0B,
    'XOR':  0x0C,
    'NOT':  0x0D,
    'SHR':  0x0E,
    'LOAD': 0x10,
    'STORE':0x11,
}

RE_COMMENT = re.compile(r'[;#].*$')
RE_LABEL = re.compile(r'^\s*([A-Za-z_]\w*):\s*$')
RE_REG = re.compile(r'R([0-7])$', re.IGNORECASE)
RE_MEM = re.compile(r'^\[\s*(R[0-7])\s*\+\s*([^\]]+)\]$', re.IGNORECASE)

def strip_comment(line: str) -> str:
    return RE_COMMENT.sub('', line).strip()

def parse_reg(token: str) -> int:
    m = RE_REG.match(token.strip())
    if not m:
        raise ValueError(f"Invalid register: {token}")
    return int(m.group(1))

def parse_imm(token: str) -> int:
    token = token.strip()
    sign = -1 if token.startswith('-') else 1
    if token.startswith(('+', '-')):
        token = token[1:].strip()
    val = int(token, 0)
    return sign * val

def imm16(value: int) -> int:
    if not -32768 <= value <= 65535:
        raise ValueError(f"Immediate out of range for 16 bits: {value}")
    return value & 0xFFFF

def tokenize_operands(operand_text: str):
    parts = []
    cur = ''
    depth = 0
    for ch in operand_text:
        if ch == '[':
            depth += 1
        elif ch == ']':
            depth -= 1
        if ch == ',' and depth == 0:
            parts.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        parts.append(cur.strip())
    return parts

def parse_line(line: str):
    line = strip_comment(line)
    if not line:
        return None
    if RE_LABEL.match(line):
        return ('label', RE_LABEL.match(line).group(1))
    parts = line.split(None, 1)
    if len(parts) == 1:
        mnemonic, operand_text = parts[0].upper(), ''
    else:
        mnemonic, operand_text = parts[0].upper(), parts[1]
    operands = tokenize_operands(operand_text)
    return ('inst', mnemonic, operands)

def first_pass(lines):
    labels = {}
    pc = 0
    parsed = []
    for raw in lines:
        item = parse_line(raw)
        if item is None:
            continue
        if item[0] == 'label':
            label = item[1]
            if label in labels:
                raise ValueError(f"Duplicate label: {label}")
            labels[label] = pc
        else:
            parsed.append(item)
            pc += 1
    return labels, parsed

def encode_inst(pc, mnemonic, operands, labels):
    op = OPCODES.get(mnemonic)
    if op is None:
        raise ValueError(f"Unknown mnemonic: {mnemonic}")

    def branch_offset(target_label):
        if target_label not in labels:
            raise ValueError(f"Unknown label: {target_label}")
        return labels[target_label] - (pc + 1)

    if mnemonic in ('ADD', 'SUB', 'AND', 'OR', 'XOR', 'NOT', 'SHL', 'SHR'):
        if len(operands) != 2:
            raise ValueError(f"{mnemonic} expects 2 operands")
        rd = parse_reg(operands[0])
        rs = parse_reg(operands[1])
        return (op << 26) | (rd << 21) | (rs << 16)

    if mnemonic == 'ADDI':
        if len(operands) != 3:
            raise ValueError("ADDI expects 3 operands")
        rd = parse_reg(operands[0])
        rs = parse_reg(operands[1])
        imm = imm16(parse_imm(operands[2]))
        return (op << 26) | (rd << 21) | (rs << 16) | imm

    if mnemonic in ('LOAD', 'STORE'):
        if len(operands) != 2:
            raise ValueError(f"{mnemonic} expects 2 operands")
        rd = parse_reg(operands[0])
        mm = RE_MEM.match(operands[1])
        if not mm:
            raise ValueError(f"Invalid memory operand: {operands[1]}")
        rs = parse_reg(mm.group(1))
        imm = imm16(parse_imm(mm.group(2)))
        return (op << 26) | (rd << 21) | (rs << 16) | imm

    if mnemonic in ('BEQ', 'BNE'):
        if len(operands) != 3:
            raise ValueError(f"{mnemonic} expects 3 operands")
        rd = parse_reg(operands[0])
        rs = parse_reg(operands[1])
        off_tok = operands[2]
        if re.match(r'^[A-Za-z_]\w*$', off_tok):
            off = branch_offset(off_tok)
        else:
            off = parse_imm(off_tok)
        imm = imm16(off)
        return (op << 26) | (rd << 21) | (rs << 16) | imm

    if mnemonic == 'JMP':
        if len(operands) != 1:
            raise ValueError("JMP expects 1 operand")
        tok = operands[0]
        if re.match(r'^[A-Za-z_]\w*$', tok):
            if tok not in labels:
                raise ValueError(f"Unknown label: {tok}")
            target = labels[tok]
        else:
            target = parse_imm(tok)
        return (op << 26) | (target & 0xFFFF)

    raise ValueError(f"Unsupported mnemonic: {mnemonic}")

def assemble(text: str):
    labels, parsed = first_pass(text.splitlines())
    words = []
    pc = 0
    for item in parsed:
        _, mnemonic, operands = item
        word = encode_inst(pc, mnemonic, operands, labels)
        words.append(f"{word:08X}")
        pc += 1
    return words

def main():
    if len(sys.argv) < 2:
        print("Usage: simple_cpu_assembler.py input.asm [output.txt]")
        sys.exit(1)
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else inp.with_suffix('.hex')
    words = assemble(inp.read_text())
    out.write_text("\n".join(words) + "\n")
    print(f"Wrote {len(words)} words to {out}")

if __name__ == "__main__":
    main()
