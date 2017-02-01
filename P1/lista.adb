--Alfonso Nombela Moreno

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Lista is
	package ASU renames Ada.Strings.Unbounded; 
	package T_IO renames Ada.Text_IO;

	function EsListaVacia ( list:  Acceso_Celda) return Boolean is 
	
	begin
		return list = null;
	end;
	
	procedure InsertarPalabras (P_Aux: in out Acceso_Celda; Palabra:ASU.Unbounded_String) is
	
		P_Lista: Acceso_Celda;
		Nueva:Boolean := True;
	
	begin
			
			P_Lista := P_Aux;
			
			while  not EsListaVacia(P_Lista) loop
				
				if ASU.To_String(P_Lista.Nombre)= ASU.To_String(Palabra)  then
				
					P_Lista.Contador:=P_Lista.Contador +1;
					Nueva := False;
				
				end if;
			
				P_Lista:=P_Lista.Siguiente;
		
			end loop;
			
			if Nueva then
				P_Lista:= new Celda;
				P_Lista.Nombre := Palabra;
				P_Lista.Siguiente := P_Aux;
				P_Aux := P_Lista;
				P_Lista.Contador := 1;
				
			end if;
	end ;
	
	procedure EscribirLista( P_Aux:  Acceso_Celda) is
	
		P_Lista: Acceso_Celda;
		P_Lista_2: Acceso_Celda;
		
	begin
	
		P_Lista:=P_Aux;
		while not EsListaVacia(P_Lista) loop
		
			T_IO.Put_Line(ASU.To_String(P_Lista.Nombre) & ":" & 
								Integer'Image(P_Lista.Contador));
			

			
			P_Lista_2:=P_Lista;
			Free(P_Lista_2);       --libera memoria de cada celda en cada pasada del bucle
			P_Lista:=P_Lista.Siguiente;
		end loop;
		
		T_IO.New_Line;
		
	end;
	
end Lista;