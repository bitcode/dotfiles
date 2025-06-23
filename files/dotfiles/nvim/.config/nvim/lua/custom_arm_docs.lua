-- ARM AArch64 Documentation Module for Neovim
-- Provides comprehensive documentation links and utilities for ARM assembly development

local M = {}

-- Cross-platform URL opening functionality
local function open_url(url)
  local cmd
  if vim.fn.has('mac') == 1 then
    cmd = 'open'
  elseif vim.fn.has('unix') == 1 then
    cmd = 'xdg-open'
  elseif vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    cmd = 'start'
  else
    vim.notify('Unsupported platform for opening URLs', vim.log.levels.ERROR)
    return false
  end
  
  local success = vim.fn.system(cmd .. ' "' .. url .. '"')
  if vim.v.shell_error ~= 0 then
    vim.notify('Failed to open URL: ' .. url, vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Comprehensive ARM AArch64 instruction documentation
M.arm_instructions = {
  -- Arithmetic Instructions
  ['add'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ADD--immediate---Add--immediate-',
  ['adds'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ADDS--immediate---Add--immediate---setting-flags-',
  ['sub'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SUB--immediate---Subtract--immediate-',
  ['subs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SUBS--immediate---Subtract--immediate---setting-flags-',
  ['adc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ADC--Add-with-Carry-',
  ['adcs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ADCS--Add-with-Carry--setting-flags-',
  ['sbc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SBC--Subtract-with-Carry-',
  ['sbcs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SBCS--Subtract-with-Carry--setting-flags-',
  ['mul'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MUL--Multiply-',
  ['madd'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MADD--Multiply-Add-',
  ['msub'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MSUB--Multiply-Subtract-',
  ['smull'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SMULL--Signed-Multiply-Long-',
  ['umull'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/UMULL--Unsigned-Multiply-Long-',
  ['sdiv'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SDIV--Signed-Divide-',
  ['udiv'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/UDIV--Unsigned-Divide-',

  -- Logical Instructions
  ['and'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/AND--immediate---Bitwise-AND--immediate-',
  ['ands'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ANDS--immediate---Bitwise-AND--immediate---setting-flags-',
  ['orr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ORR--immediate---Bitwise-OR--immediate-',
  ['eor'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/EOR--immediate---Bitwise-Exclusive-OR--immediate-',
  ['bic'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BIC--Bitwise-Bit-Clear--shifted-register-',
  ['bics'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BICS--Bitwise-Bit-Clear--shifted-register---setting-flags-',
  ['orn'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ORN--shifted-register---Bitwise-OR-NOT--shifted-register-',
  ['eon'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/EON--Bitwise-Exclusive-OR-NOT--shifted-register-',

  -- Shift and Rotate Instructions
  ['lsl'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LSL--immediate---Logical-Shift-Left--immediate---an-alias-of-UBFM-',
  ['lsr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LSR--immediate---Logical-Shift-Right--immediate---an-alias-of-UBFM-',
  ['asr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ASR--immediate---Arithmetic-Shift-Right--immediate---an-alias-of-SBFM-',
  ['ror'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ROR--immediate---Rotate-Right--immediate---an-alias-of-EXTR-',
  ['rrx'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/RRX--Rotate-Right-with-Extend--an-alias-of-RRX-',

  -- Move Instructions
  ['mov'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MOV--register---Move--register---an-alias-of-ORR--shifted-register--',
  ['movz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MOVZ--Move-wide-with-zero-',
  ['movn'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MOVN--Move-wide-with-NOT-',
  ['movk'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MOVK--Move-wide-with-keep-',
  ['mvn'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MVN--Bitwise-NOT--shifted-register---an-alias-of-ORN--shifted-register--',

  -- Load/Store Instructions
  ['ldr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDR--immediate---Load-Register--immediate-',
  ['ldrb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDRB--immediate---Load-Register-Byte--immediate-',
  ['ldrh'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDRH--immediate---Load-Register-Halfword--immediate-',
  ['ldrsb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDRSB--immediate---Load-Register-Signed-Byte--immediate-',
  ['ldrsh'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDRSH--immediate---Load-Register-Signed-Halfword--immediate-',
  ['ldrsw'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDRSW--immediate---Load-Register-Signed-Word--immediate-',
  ['str'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STR--immediate---Store-Register--immediate-',
  ['strb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STRB--immediate---Store-Register-Byte--immediate-',
  ['strh'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STRH--immediate---Store-Register-Halfword--immediate-',
  ['ldp'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDP--Load-Pair-of-Registers-',
  ['stp'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STP--Store-Pair-of-Registers-',
  ['ldur'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDUR--Load-Register--unscaled-',
  ['stur'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STUR--Store-Register--unscaled-',

  -- Branch Instructions
  ['b'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B--Branch-',
  ['bl'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BL--Branch-with-Link-',
  ['br'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BR--Branch-to-Register-',
  ['blr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BLR--Branch-with-Link-to-Register-',
  ['ret'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/RET--Return-from-subroutine-',
  ['cbz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CBZ--Compare-and-Branch-on-Zero-',
  ['cbnz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CBNZ--Compare-and-Branch-on-Nonzero-',
  ['tbz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/TBZ--Test-bit-and-Branch-if-Zero-',
  ['tbnz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/TBNZ--Test-bit-and-Branch-if-Nonzero-',

  -- Conditional Branch Instructions
  ['b.eq'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.ne'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.cs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.cc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.mi'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.pl'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.vs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.vc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.hi'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.ls'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.ge'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.lt'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.gt'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.le'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',
  ['b.al'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/B-cond--Branch--conditional-',

  -- Compare Instructions
  ['cmp'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CMP--immediate---Compare--immediate---an-alias-of-SUBS--immediate--',
  ['cmn'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CMN--immediate---Compare-Negative--immediate---an-alias-of-ADDS--immediate--',
  ['tst'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/TST--immediate---Test--immediate---an-alias-of-ANDS--immediate--',
  ['teq'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/TST--immediate---Test--immediate---an-alias-of-ANDS--immediate--',

  -- Conditional Select Instructions
  ['csel'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CSEL--Conditional-Select-',
  ['csinc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CSINC--Conditional-Select-Increment-',
  ['csinv'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CSINV--Conditional-Select-Invert-',
  ['csneg'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CSNEG--Conditional-Select-Negation-',
  ['cset'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CSET--Conditional-Set--an-alias-of-CSINC-',
  ['csetm'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CSETM--Conditional-Set-Mask--an-alias-of-CSINV-',
  ['cinc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CINC--Conditional-Increment--an-alias-of-CSINC-',
  ['cinv'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CINV--Conditional-Invert--an-alias-of-CSINV-',
  ['cneg'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CNEG--Conditional-Negate--an-alias-of-CSNEG-',

  -- Bit Field Instructions
  ['sbfm'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SBFM--Signed-Bitfield-Move-',
  ['ubfm'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/UBFM--Unsigned-Bitfield-Move-',
  ['bfm'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BFM--Bitfield-Move-',
  ['sbfiz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SBFIZ--Signed-Bitfield-Insert-in-Zero--an-alias-of-SBFM-',
  ['sbfx'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SBFX--Signed-Bitfield-Extract--an-alias-of-SBFM-',
  ['ubfiz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/UBFIZ--Unsigned-Bitfield-Insert-in-Zero--an-alias-of-UBFM-',
  ['ubfx'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/UBFX--Unsigned-Bitfield-Extract--an-alias-of-UBFM-',
  ['bfi'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BFI--Bitfield-Insert--an-alias-of-BFM-',
  ['bfxil'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BFXIL--Bitfield-extract-and-insert-at-low-end--an-alias-of-BFM-',

  -- Extract Instructions
  ['extr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/EXTR--Extract-register-',

  -- Count Instructions
  ['clz'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CLZ--Count-Leading-Zeros-',
  ['cls'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/CLS--Count-Leading-Sign-bits-',
  ['rbit'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/RBIT--Reverse-Bits-',
  ['rev'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/REV--Reverse-Bytes-',
  ['rev16'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/REV16--Reverse-bytes-in-16-bit-halfwords-',
  ['rev32'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/REV32--Reverse-bytes-in-32-bit-words-',

  -- System Instructions
  ['nop'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/NOP--No-Operation-',
  ['wfi'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/WFI--Wait-For-Interrupt-',
  ['wfe'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/WFE--Wait-For-Event-',
  ['sev'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SEV--Send-Event-',
  ['sevl'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SEVL--Send-Event-Local-',
  ['yield'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/YIELD--YIELD-',
  ['isb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/ISB--Instruction-Synchronization-Barrier-',
  ['dsb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/DSB--Data-Synchronization-Barrier-',
  ['dmb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/DMB--Data-Memory-Barrier-',

  -- System Register Instructions
  ['mrs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MRS--Move-System-Register-',
  ['msr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/MSR--immediate---Move-immediate-to-Special-Register-',

  -- Exception Instructions
  ['svc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SVC--Supervisor-Call-',
  ['hvc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/HVC--Hypervisor-Call-',
  ['smc'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/SMC--Secure-Monitor-Call-',
  ['brk'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/BRK--Breakpoint-instruction-',
  ['hlt'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/HLT--Halt-instruction-',

  -- Atomic Instructions
  ['ldxr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDXR--Load-Exclusive-Register-',
  ['ldxrb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDXRB--Load-Exclusive-Register-Byte-',
  ['ldxrh'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDXRH--Load-Exclusive-Register-Halfword-',
  ['stxr'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STXR--Store-Exclusive-Register-',
  ['stxrb'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STXRB--Store-Exclusive-Register-Byte-',
  ['stxrh'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STXRH--Store-Exclusive-Register-Halfword-',
  ['ldxp'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/LDXP--Load-Exclusive-Pair-of-Registers-',
  ['stxp'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/Base-Instructions/STXP--Store-Exclusive-Pair-of-registers-',

  -- Advanced SIMD (NEON) Instructions
  ['ld1'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/LD1--single-structure---Load-one-single-element-structure-to-one-lane-of-one-register-',
  ['st1'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/ST1--single-structure---Store-a-single-element-structure-from-one-lane-of-one-register-',
  ['ld2'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/LD2--single-structure---Load-single-2-element-structure-to-one-lane-of-two-registers-',
  ['st2'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/ST2--single-structure---Store-single-2-element-structure-from-one-lane-of-two-registers-',
  ['ld3'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/LD3--single-structure---Load-single-3-element-structure-to-one-lane-of-three-registers-',
  ['st3'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/ST3--single-structure---Store-single-3-element-structure-from-one-lane-of-three-registers-',
  ['ld4'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/LD4--single-structure---Load-single-4-element-structure-to-one-lane-of-four-registers-',
  ['st4'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/ST4--single-structure---Store-single-4-element-structure-from-one-lane-of-four-registers-',

  -- Floating Point Instructions
  ['fadd'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FADD--scalar---Floating-point-Add--scalar--',
  ['fsub'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FSUB--scalar---Floating-point-Subtract--scalar--',
  ['fmul'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FMUL--scalar---Floating-point-Multiply--scalar--',
  ['fdiv'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FDIV--scalar---Floating-point-Divide--scalar--',
  ['fmadd'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FMADD--Floating-point-fused-Multiply-Add--scalar--',
  ['fmsub'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FMSUB--Floating-point-fused-Multiply-Subtract--scalar--',
  ['fnmadd'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FNMADD--Floating-point-negated-fused-Multiply-Add--scalar--',
  ['fnmsub'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FNMSUB--Floating-point-negated-fused-Multiply-Subtract--scalar--',
  ['fabs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FABS--scalar---Floating-point-Absolute-value--scalar--',
  ['fneg'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FNEG--scalar---Floating-point-Negate--scalar--',
  ['fsqrt'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FSQRT--scalar---Floating-point-Square-Root--scalar--',
  ['fcmp'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCMP--Floating-point-Compare--scalar--',
  ['fcmpe'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCMPE--Floating-point-Compare-with-Exception--scalar--',
  ['fmov'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FMOV--register---Floating-point-Move--register--',
  ['fcvt'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVT--Floating-point-Convert-precision--scalar--',
  ['fcvtas'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTAS--scalar---Floating-point-Convert-to-Signed-integer--round-to-nearest-with-ties-to-Away--scalar--',
  ['fcvtau'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTAU--scalar---Floating-point-Convert-to-Unsigned-integer--round-to-nearest-with-ties-to-Away--scalar--',
  ['fcvtms'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTMS--scalar---Floating-point-Convert-to-Signed-integer--round-toward-Minus-infinity--scalar--',
  ['fcvtmu'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTMU--scalar---Floating-point-Convert-to-Unsigned-integer--round-toward-Minus-infinity--scalar--',
  ['fcvtns'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTNS--scalar---Floating-point-Convert-to-Signed-integer--round-toward-Nearest--scalar--',
  ['fcvtnu'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTNU--scalar---Floating-point-Convert-to-Unsigned-integer--round-toward-Nearest--scalar--',
  ['fcvtps'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTPS--scalar---Floating-point-Convert-to-Signed-integer--round-toward-Plus-infinity--scalar--',
  ['fcvtpu'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTPU--scalar---Floating-point-Convert-to-Unsigned-integer--round-toward-Plus-infinity--scalar--',
  ['fcvtzs'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTZS--scalar--integer---Floating-point-Convert-to-Signed-integer--round-toward-Zero--scalar--',
  ['fcvtzu'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/FCVTZU--scalar--integer---Floating-point-Convert-to-Unsigned-integer--round-toward-Zero--scalar--',
  ['scvtf'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/SCVTF--scalar--integer---Signed-integer-Convert-to-Floating-point--scalar--',
  ['ucvtf'] = 'https://developer.arm.com/documentation/ddi0596/2021-12/SIMD-FP-Instructions/UCVTF--scalar--integer---Unsigned-integer-Convert-to-Floating-point--scalar--',
}

-- System registers documentation
M.system_registers = {
  ['spsr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/SPSR-EL1--Saved-Program-Status-Register--EL1-',
  ['elr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/ELR-EL1--Exception-Link-Register--EL1-',
  ['midr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/MIDR-EL1--Main-ID-Register',
  ['mpidr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/MPIDR-EL1--Multiprocessor-Affinity-Register',
  ['currentel'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/CurrentEL--Current-Exception-Level',
  ['daif'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/DAIF--Interrupt-Mask-Bits',
  ['nzcv'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/NZCV--Condition-Flags',
  ['sp_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/SP-EL0--Stack-Pointer--EL0-',
  ['sp_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/SP-EL1--Stack-Pointer--EL1-',
  ['sctlr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/SCTLR-EL1--System-Control-Register--EL1-',
  ['tcr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/TCR-EL1--Translation-Control-Register--EL1-',
  ['ttbr0_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/TTBR0-EL1--Translation-Table-Base-Register-0--EL1-',
  ['ttbr1_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/TTBR1-EL1--Translation-Table-Base-Register-1--EL1-',
  ['mair_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/MAIR-EL1--Memory-Attribute-Indirection-Register--EL1-',
  ['vbar_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/VBAR-EL1--Vector-Base-Address-Register--EL1-',
  ['esr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/ESR-EL1--Exception-Syndrome-Register--EL1-',
  ['far_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/FAR-EL1--Fault-Address-Register--EL1-',
  ['par_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/PAR-EL1--Physical-Address-Register--EL1-',
  ['tpidr_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/TPIDR-EL0--EL0-Read-Write-Software-Thread-ID-Register',
  ['tpidr_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/TPIDR-EL1--EL1-Software-Thread-ID-Register',
  ['tpidrro_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/TPIDRRO-EL0--EL0-Read-Only-Software-Thread-ID-Register',
  ['cntkctl_el1'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/CNTKCTL-EL1--Counter-timer-Kernel-Control-register',
  ['cntfrq_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/CNTFRQ-EL0--Counter-timer-Frequency-register',
  ['cntp_ctl_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/CNTP-CTL-EL0--Counter-timer-Physical-Timer-Control-register',
  ['cntp_cval_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/CNTP-CVAL-EL0--Counter-timer-Physical-Timer-CompareValue-register',
  ['cntpct_el0'] = 'https://developer.arm.com/documentation/ddi0595/2021-12/AArch64-Registers/CNTPCT-EL0--Counter-timer-Physical-Count-register',
}

-- General-purpose registers documentation
M.general_registers = {
  ['x0'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x1'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x2'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x3'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x4'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x5'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x6'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x7'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x8'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x9'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x10'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x11'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x12'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x13'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x14'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x15'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x16'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x17'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x18'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x19'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x20'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x21'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x22'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x23'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x24'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x25'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x26'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x27'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x28'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x29'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['x30'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['sp'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['lr'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['pc'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  -- 32-bit register variants
  ['w0'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w1'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w2'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w3'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w4'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w5'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w6'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w7'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w8'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w9'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w10'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w11'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w12'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w13'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w14'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w15'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w16'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w17'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w18'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w19'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w20'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w21'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w22'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w23'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w24'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w25'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w26'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w27'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w28'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w29'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
  ['w30'] = 'https://developer.arm.com/documentation/102374/0101/Registers-in-AArch64---general-purpose-registers',
}

-- Function to get documentation URL for a word
function M.get_documentation_url(word)
  local lower_word = string.lower(word)
  
  -- Check instruction documentation first
  if M.arm_instructions[lower_word] then
    return M.arm_instructions[lower_word]
  end
  
  -- Check system registers
  if M.system_registers[lower_word] then
    return M.system_registers[lower_word]
  end
  
  -- Check general-purpose registers
  if M.general_registers[lower_word] then
    return M.general_registers[lower_word]
  end
  
  return nil
end

-- Function to open ARM documentation for word under cursor
function M.open_arm_docs_for_word()
  local word = vim.fn.expand('<cword>')
  if not word or word == '' then
    vim.notify('No word under cursor', vim.log.levels.WARN)
    return
  end
  
  local url = M.get_documentation_url(word)
  if url then
    if open_url(url) then
      vim.notify('Opening ARM documentation for: ' .. word, vim.log.levels.INFO)
    end
  else
    -- Fallback to general ARM documentation search
    local search_url = 'https://developer.arm.com/search#q=' .. word .. '&f:@navigationhierarchiescontenttype=[Reference%20Manual]'
    if open_url(search_url) then
      vim.notify('Searching ARM documentation for: ' .. word, vim.log.levels.INFO)
    end
  end
end

-- Function to list available instructions for completion
function M.get_instruction_list()
  local instructions = {}
  for instruction, _ in pairs(M.arm_instructions) do
    table.insert(instructions, instruction)
  end
  table.sort(instructions)
  return instructions
end

-- Function to get instruction info for hover
function M.get_instruction_info(instruction)
  local lower_instruction = string.lower(instruction)
  local url = M.arm_instructions[lower_instruction]
  if url then
    return {
      instruction = instruction,
      url = url,
      description = 'ARM AArch64 instruction - click to view documentation'
    }
  end
  return nil
end

-- Setup function to initialize keymaps and commands
function M.setup()
  -- Create user command for ARM documentation lookup
  vim.api.nvim_create_user_command('ArmDocs', function(opts)
    if opts.args and opts.args ~= '' then
      local url = M.get_documentation_url(opts.args)
      if url then
        open_url(url)
        vim.notify('Opening ARM documentation for: ' .. opts.args, vim.log.levels.INFO)
      else
        local search_url = 'https://developer.arm.com/search#q=' .. opts.args .. '&f:@navigationhierarchiescontenttype=[Reference%20Manual]'
        open_url(search_url)
        vim.notify('Searching ARM documentation for: ' .. opts.args, vim.log.levels.INFO)
      end
    else
      M.open_arm_docs_for_word()
    end
  end, {
    nargs = '?',
    desc = 'Open ARM AArch64 documentation for instruction or word under cursor',
    complete = function(arglead, cmdline, cursorpos)
      local instructions = M.get_instruction_list()
      local matches = {}
      for _, instruction in ipairs(instructions) do
        if string.match(instruction, '^' .. arglead) then
          table.insert(matches, instruction)
        end
      end
      return matches
    end
  })
  
  -- Create command to list all available instructions
  vim.api.nvim_create_user_command('ArmInstructions', function()
    local instructions = M.get_instruction_list()
    local lines = {'Available ARM AArch64 Instructions:', ''}
    for i, instruction in ipairs(instructions) do
      table.insert(lines, string.format('%3d. %s', i, instruction))
    end
    
    -- Create a new buffer to display the instructions
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_name(buf, 'ARM Instructions')
    
    -- Open in a new window
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_win_set_height(0, math.min(#lines, 20))
  end, {
    desc = 'List all available ARM AArch64 instructions'
  })
end

return M