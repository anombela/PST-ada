--Alfonso Nombela Moreno

with Pantalla;
with Prompt;
with Ada.Text_IO;
With Ada.Strings.Unbounded;

package Debug is


	procedure Asigna_Nombre (Apodo:Ada.Strings.Unbounded.Unbounded_String);
	
	procedure Set_Status (Status: Boolean);

  
	function Get_Status return Boolean;

   
	procedure Put_Line (Msg         : String;
					Color_Msg   : Pantalla.T_Color);
	
   
  
	procedure Put      (Msg         : String;
				Color_Msg   : Pantalla.T_Color := Pantalla.Verde);


end Debug;
