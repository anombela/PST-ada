--Alfonso Nombela Moreno

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package Lista is

	type Celda;
	type Acceso_Celda is access Celda;

	type Celda is record
		Nombre : Ada.Strings.Unbounded.Unbounded_String;
		Contador: Integer := 0;
		Siguiente : Acceso_Celda;
	end record;
	procedure Free is new
		Ada.Unchecked_Deallocation
		(Celda,  Acceso_Celda);

	
	procedure InsertarPalabras (P_Aux: in out Acceso_Celda; 
							Palabra:Ada.Strings.Unbounded.Unbounded_String);
							
	procedure EscribirLista( P_Aux:  Acceso_Celda);
	
end Lista;