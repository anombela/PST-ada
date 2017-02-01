--Alfonso Nombela Moreno
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;

package body Handlers is

	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	package ASU renames Ada.Strings.Unbounded;


	procedure Client_Handler (From    : in     LLU.End_Point_Type;
						To      : in     LLU.End_Point_Type;
						P_Buffer: access LLU.Buffer_Type) is
			     
		Mensaje_Comentario: ASU.Unbounded_String;
		Mensaje_Tipo : CM.Message_Type;
		Mensaje_Nick: ASU.Unbounded_String;
	begin
		
		-------------RECIVE MENSAJE SERVIDOR----
		-- saca del Buffer P_Buffer.all un Unbounded_String
		Mensaje_Tipo := CM.Message_Type'Input (P_Buffer);
		Mensaje_Nick := ASU.Unbounded_String'Input (P_Buffer);
		Mensaje_Comentario := ASU.Unbounded_String'Input(P_Buffer);
		Ada.Text_IO.New_Line;
		if ASU.TO_String(Mensaje_Nick)="servidor" then
			Ada.Text_IO.Put_Line(ASU.To_String(Mensaje_Nick) &(": ")&
							ASU.To_String(Mensaje_Comentario));
		else
			Ada.Text_IO.Put_Line(ASU.To_String(Mensaje_Nick) &(": ")&
							ASU.To_String(Mensaje_Comentario));
		end if;
		
	Ada.Text_IO.Put(">> ");
		
	end Client_Handler;

end Handlers;

