--Alfonso Nombela Moreno

with Ada.Text_IO;

package body Prompt is

	Do_Prompt : Boolean := False;
   
	procedure Set_Status (Status: Boolean) is
	begin
		Do_Prompt := Status;
	end Set_Status;
   
   
	function Get_Status return Boolean is
	begin
		return Do_Prompt;
	end Get_Status;
   
   
	procedure Put_Line (Msg         : String;
					Color_Msg   : Pantalla.T_Color ) is
	begin
		if Do_Prompt then
			Pantalla.Poner_Color(Color_Msg);
			Ada.Text_IO.Put_Line(Msg);
			Pantalla.Poner_Color(Pantalla.Cierra);	 
		end if;
	end Put_Line;

end Prompt;
