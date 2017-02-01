--Alfonso Nombela Moreno

package body Debug is

	Do_Debug : Boolean := True;
	Nombre:Ada.Strings.Unbounded.Unbounded_String;
   
	procedure Asigna_Nombre (Apodo:Ada.Strings.Unbounded.Unbounded_String) is
	begin
		Nombre := Apodo;
	end Asigna_Nombre;
	
	procedure Set_Status (Status: Boolean) is
	begin
		Do_Debug := Status;
	end Set_Status;
   
   
	function Get_Status return Boolean is
	begin
		return Do_Debug;
	end Get_Status;
   
   
	procedure Put_Line (Msg         : String;
					Color_Msg   : Pantalla.T_Color ) is
	begin
		if Do_Debug then
			
			Pantalla.Poner_Color(Color_Msg);
			Ada.Text_IO.Put_Line(Msg);
			Pantalla.Poner_Color(Pantalla.Cierra);
			Prompt.Put_Line(Ada.Strings.Unbounded.To_String(Nombre)&" >> ",Pantalla.Blanco);	 
		end if;
	end Put_Line;


	procedure Put (Msg         : String;
				Color_Msg   : Pantalla.T_Color := Pantalla.Verde) is
	begin
		if Do_Debug then
			
			Pantalla.Poner_Color(Color_Msg);
			Ada.Text_IO.Put(Msg);
			Pantalla.Poner_Color(Pantalla.Cierra);
			Prompt.Put_Line("",Pantalla.Blanco);
			
		end if;
	end Put;

end Debug;
