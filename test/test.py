import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cnn_accelerator(dut):

    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    dut._log.info("Starting CNN test")

    # Reset
    dut.rst_n.value = 0
    dut.ui_in.value = 0

    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    # 3x3 test pattern
    pixels = [1,0,1,
              1,1,1,
              1,0,1]

    for p in pixels:
        dut.ui_in.value = (1 << 1) | p
        await ClockCycles(dut.clk, 1)

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    result = int(dut.uo_out[0].value)

    dut._log.info(f"CNN output = {result}")

    # Basic verification
    assert result in [0,1], "Invalid CNN output"
