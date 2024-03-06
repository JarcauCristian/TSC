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

  parameter WR_NR = 20;
  parameter RD_NR = 20;
  instruction_t iw_reg [0:31];

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
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

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
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
      @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
      check_result;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
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
    static int temp = 0;
    operand_t op_a, op_b;
    opcode_t opc;
    int wp;

    op_a     = $random(seed)%16;                 // between -15 and 15
    op_b     = $unsigned($random)%16;            // between 0 and 15
    opc        = opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    wp = temp++; //write temp to local variable
    write_pointer <= wp; // write_pointer primeste 0 la inceput


    operand_a <= op_a; //put the calculated variable from above inside the registers
    operand_b <= op_b; //put the calculated variable from above inside the registers
    opcode <= opc; //put the calculated variable from above inside the registers
    
    iw_reg[wp] = '{opc,op_a,op_b,{64{1'b0}}};
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
    operand_d_t result;
    case (iw_reg[read_pointer].opc)
        ZERO : result = {64{1'b0}};
        PASSA : result = iw_reg[read_pointer].op_a;
        PASSB : result = iw_reg[read_pointer].op_b;
        ADD : result = iw_reg[read_pointer].op_a + iw_reg[read_pointer].op_b;
        SUB : result = iw_reg[read_pointer].op_a - iw_reg[read_pointer].op_b;
        MULT : result = iw_reg[read_pointer].op_a * iw_reg[read_pointer].op_b;
        DIV : 
        if (iw_reg[read_pointer].op_b === {32{1'b0}})
          result = 'b0;
        else
          result = iw_reg[read_pointer].op_a / iw_reg[read_pointer].op_b;
        MOD : result = iw_reg[read_pointer].op_a % iw_reg[read_pointer].op_b;
    endcase 

    $display("\nCheck Result:");
    $display("  read_pointer = %0d", read_pointer);
    $display("  opcode = %0d (%s)", iw_reg[read_pointer].opc, iw_reg[read_pointer].opc.name);
    $display("  operand_a = %0d",   iw_reg[read_pointer].op_a);
    $display("  operand_b = %0d", iw_reg[read_pointer].op_b);

    $display("\nCalculated Test Result: %0d\n", result);

    if (result === instruction_word.result) 
    begin
      $display("Results are matching!\n");
    end
    else
    begin
      $display("Results are not matching!\n");
    end
  endfunction: check_result

endmodule: instr_register_test
