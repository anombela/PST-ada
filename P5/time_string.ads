--Alfonso Nombela Moreno

with Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Unbounded;
with Gnat.Calendar.Time_IO;
with Lower_Layer_UDP;

package Time_String is
	package ASU renames Ada.Strings.Unbounded;
	package C_IO renames Gnat.Calendar.Time_IO;
	package LLU renames Lower_Layer_UDP;
	package T_IO renames Ada.Text_IO;
	use Type LLU.End_Point_Type;
   
	
	
	function Image (T: Ada.Calendar.Time) return String;
	function Image2 (T: Ada.Calendar.Time) return String;
	function Image3 (T: Ada.Calendar.Time) return String;
	
   
 end Time_String;
