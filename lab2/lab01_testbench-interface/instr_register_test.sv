/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n, // Testul genereaza semnale => catrea dut => genereaza un rezultat catre test;
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;

  int seed = 555;
  int passed_tests = 0;
  int total_tests = 0;

  parameter WR_NR = 20;
  parameter RD_NR = 3;
  parameter ORDER_OPTIONS = 3;
  parameter WRITE_ORDER = 0;
  parameter READ_ORDER = 0;
  parameter TEST_NAME = "";
  instruction_t iw_reg_test [0:31];

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS A SELF-CHECKING TESTBENCH.  YOU DON'T  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");

    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    $display("\nWriting values to register stack...");
     //repeat (3) begin JSC 06.03.2024
     repeat (WR_NR) begin
       @(posedge clk) randomize_transaction;
       @(negedge clk) print_transaction;
     end
     @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<RD_NR; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge clk) 
      if (READ_ORDER == 0) read_pointer = i;
      else if (READ_ORDER == 1) read_pointer = 31 - (i % 32);
      else if (READ_ORDER == 2) read_pointer = $unsigned($random%32);
      @(negedge clk) print_results;
      check_result;
    end
    @(posedge clk) ;
    final_report;
    $display("\nNumber of tests passed out of all tests for: %0d/%0d", passed_tests, total_tests);
    $display("\n***********************************************************");
    $display(  "***  THIS IS A SELF-CHECKING TESTBENCH.  YOU DON'T  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    if (WRITE_ORDER == 0)
    begin
      static int temp = 0;
      write_pointer = temp++;
    end
    else if (WRITE_ORDER == 1)
    begin
      static int temp = 31;
      write_pointer = temp--;
    end
    else if (WRITE_ORDER == 2)
    begin
      write_pointer = $unsigned($random)%32;
    end
    else 
    begin
      static int temp = 0;
      write_pointer = temp++;
    end

    operand_a = $random(seed)%16; //put the calculated variable from above inside the registers
    operand_b = $unsigned($random)%16; //put the calculated variable from above inside the registers
    opcode = opcode_t'($unsigned($random)%8); //put the calculated variable from above inside the registers

    iw_reg_test[write_pointer] = '{opcode,operand_a,operand_b,{64{1'b0}}};
    $display("Randomized Transaction Display for Position: %0d", write_pointer);
    $display("operand_a: %0d", iw_reg_test[write_pointer].op_a);
    $display("operand_b: %0d", iw_reg_test[write_pointer].op_b);
    $display("opcode: %0d", iw_reg_test[write_pointer].opc);
    $display("Time: %0t\n", $time);
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  result    = %0d", instruction_word.result);
  endfunction: print_results

  function void check_result;
   $display("  read_pointer = %0d", read_pointer);
    if ((instruction_word.op_a === iw_reg_test[read_pointer].op_a) && (instruction_word.op_b === iw_reg_test[read_pointer].op_b) && (instruction_word.opc === iw_reg_test[read_pointer].opc))
    begin
      operand_d_t result;
      $display("\nWhat was stored in test matches what came from DUT. Starting cheking if results are matching.");
      case (iw_reg_test[read_pointer].opc)
          ZERO : result = {64{1'b0}};
          PASSA : result = iw_reg_test[read_pointer].op_a;
          PASSB : result = iw_reg_test[read_pointer].op_b;
          ADD : result = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
          SUB : result = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
          MULT : result = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
          DIV : 
          if (iw_reg_test[read_pointer].op_b === {32{1'b0}})
            result = 'b0;
          else
            result = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
          MOD : result = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
      endcase

      $display("\nCheck Result:");
      $display("  read_pointer = %0d", read_pointer);
      $display("  opcode = %0d (%s)", iw_reg_test[read_pointer].opc, iw_reg_test[read_pointer].opc.name);
      $display("  operand_a = %0d",   iw_reg_test[read_pointer].op_a);
      $display("  operand_b = %0d", iw_reg_test[read_pointer].op_b);

      $display("\nCalculated Test Result: %0d\n", result);
      $display(" instruction_word.res = %0d\n", instruction_word.result);

      if (result === instruction_word.result) 
      begin
        $display("Results are matching!\n");
        passed_tests++;
      end
      else
      begin
        $display("Results are not matching!\n");
      end
    end
    else
    begin
      $display("What was stored in test does not match what was read from DUT.\n");
    end
    total_tests++;
  endfunction: check_result

  function void reset_iw_reg_test;
    for (int i = 0; i < 32; i++)
    begin
      iw_reg_test[i] = '{opc:ZERO,default:0};
    end
  endfunction:reset_iw_reg_test

  function void final_report;
    int file;
    file = $fopen("../reports/regression_status.txt", "a");
    if (passed_tests != total_tests)
    begin
      $fdisplay(file, "%s: failed", TEST_NAME);
    end
    else
    begin
      $fdisplay(file, "%s: passed", TEST_NAME);
    end
    $fclose(file);
  endfunction:final_report

endmodule: instr_register_test
