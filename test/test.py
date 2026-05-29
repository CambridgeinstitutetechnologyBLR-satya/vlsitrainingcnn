import cocotb
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_cnn_accelerator(dut):

    dut._log.info("Starting CNN verification...")

    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 5)

    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    test_pixels = [1,0,1,1,1,1,1,0,1]

    for pixel in test_pixels:
        dut.ui_in.value = (1 << 1) | pixel
        await ClockCycles(dut.clk, 1)

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    result = dut.uo_out[0].value

    dut._log.info(f"CNN Output = {result}")
