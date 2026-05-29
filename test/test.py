import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting Tiny Tapeout CNN Hardware Simulation...")

    # 1. Initialize and start the clock (10us period = 100kHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # 2. Initialize input signals to safe default states (Avoids 'X' undefined state errors)
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1

    # 3. Apply Active-Low Reset
    dut._log.info("Applying system reset...")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)  # Hold reset for 10 clock cycles
    dut.rst_n.value = 1              # Release reset
    await ClockCycles(dut.clk, 2)   # Wait for stability
    dut._log.info("System reset released successfully.")

    # 4. Test Case: Feed sample data into the CNN hardware via ui_in
    dut._log.info("Driving input values to the hardware accumulator...")
    
    # Cycle 1: Feed data value 5
    dut.ui_in.value = 5
    await RisingEdge(dut.clk)
    
    # Cycle 2: Feed data value 10
    dut.ui_in.value = 10
    await RisingEdge(dut.clk)

    # Cycle 3: Return input to 0 and allow final calculation to settle
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 2)

    # 5. Assertions: Crosscheck that the hardware output matches expectations (5 + 10 = 15)
    expected_value = 15
    observed_value = int(dut.uo_out.value)
    
    dut._log.info(f"Hardware Output Observed: {observed_value} | Expected: {expected_value}")
    
    assert observed_value == expected_value, f"Test failed! Expected {expected_value}, got {observed_value}"
    dut._log.info("All CNN hardware checks passed successfully!")
