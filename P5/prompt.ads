--Alfonso Nombela Moreno

with Pantalla;

package Prompt is


  
	procedure Set_Status (Status: Boolean);

  
	function Get_Status return Boolean;

   
	procedure Put_Line (Msg         : String;
					Color_Msg   : Pantalla.T_Color);


end Prompt;
