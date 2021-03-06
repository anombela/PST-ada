with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;

package Chat_Messages is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	
	type Message_Type is (Init, Writer, Server);
	
	type Mensaje is record
		Tipo : Message_Type;
		EP: LLU.End_Point_Type;
		Comentario: ASU.Unbounded_String;
		Nick: ASU.Unbounded_String;
	end record;
	
end Chat_Messages;
 

