--Alfonso Nombela Moreno

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Lista;

package body  Cuenta_Palabras is 

	package ASU renames Ada.Strings.Unbounded; 
	package T_IO renames Ada.Text_IO;
	
	P_Aux :  Lista.Acceso_Celda;
	
	procedure Escribe_Palabras (C: in out Integer;
						      T: in out Ada.Strings.Unbounded.Unbounded_String) is
	
	begin
		
		C :=C+1;
		T_IO.Put_Line ("palabra " & Integer'Image(C) & " :  " & ASU.To_String(T));
		
	end;
	
	procedure Numero (C2: in out Integer;
						      N: in out Integer) is
						      
	begin
		T_IO.Put ("Total:");
		if C2 = 1 then 
			T_IO.Put(Integer'Image(C2) & " palabra y");
		else 
			T_IO.Put(Integer'Image(C2) & " palabras y");
		end if;
			
		if (C2+N) = 1 then 
			T_IO.Put(Integer'Image(C2+N) & " espacio.");
		else 
			T_IO.Put(Integer'Image(C2+N) & " espacios.");
		end if;
			
	end;
	
	procedure Trocear (T1: in out ASU.Unbounded_String;
					P: out  Integer;
					P_A: in out ASU.Unbounded_String;
					T2: in out ASU.Unbounded_String;
					Ne: in out Integer;
					Con: in out Integer;
					Valor:in Integer;
					Fich: in out Ada.Text_IO.File_Type) is
					
	begin
		
		if Valor = 0 then
			loop
				begin
				P := ASU.Index(T2, " ");  --posicion en la que se encuentra el espacio
				P_A := ASU.Head (T2, P-1);  --devuelve un trozo del principio
		
				if (ASU.Index (T2," ")=1) then
					T2:=  ASU.Tail (T2, ASU.Length(T2)-P);
					Ne := Ne + 1;
	
				else 
					
					
					Escribe_Palabras (Con, P_A);
					T2:=  ASU.Tail (T2, ASU.Length(T2)-P);
		
				end if;
				exception
					when Constraint_Error =>
						if ASU.Length(T2) = ASU.Length(T1) and ASU.To_String(T2) /= ("") then 
							Escribe_Palabras (Con,  T2);
						
							Ne := Ne - Con;
						end if;
					
						
				end;
			exit when(ASU.Index(T2," ") =0);
			end loop;
	
			if ASU.Length(T2) /= ASU.Length(T1) and ASU.To_String(T2) /= ("") then
				
				Escribe_Palabras (Con, T2);
				Ne := Ne -1 ;                                                 
	
			end if;
	
			Numero ( Con, Ne );
				
			
		else
			loop
				begin
				
				P := ASU.Index(T2, " ");  --posicion en la que se encuentra el espacio
				P_A := ASU.Head (T2, P-1);  --devuelve un trozo del principio
		
				if (ASU.Index (T2," ")=1) then
					T2:=  ASU.Tail (T2, ASU.Length(T2)-P);
					
				else 
				
					Con :=Con+1;
					Lista.InsertarPalabras(P_Aux, P_A);
					T2:=  ASU.Tail (T2, ASU.Length(T2)-P);
		
				end if;
				
				exception
					when Constraint_Error =>
						if ASU.Length(T2) = ASU.Length(T1) and ASU.To_String(T2) /= ("") then 
							Con :=Con+1;
							Lista.InsertarPalabras(P_Aux, T2);	
							
						end if;
				end;
				
			exit when(ASU.Index(T2," ") =0);
			end loop;
	
			if ASU.Length(T2) /= ASU.Length(T1) and ASU.To_String(T2) /= ("") then
				
				Con :=Con+1;
				Lista.InsertarPalabras(P_Aux, T2);
			
			end if;
			
		end if;
		
	end Trocear;
	
	procedure Palabras_Lista is
		
	begin
	
		Lista.EscribirLista(P_Aux);
		
	end Palabras_Lista;
	
end Cuenta_Palabras;
