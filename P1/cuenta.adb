--Alfonso Nombela Moreno

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Cuenta_Palabras;
with Ada.IO_Exceptions;
with Ada.Command_Line;




procedure Cuenta is
	package ASU renames Ada.Strings.Unbounded; 
	package T_IO renames Ada.Text_IO;
	
	procedure Escribir_Analisis (L: in Integer; Co : in Integer; Ca : in Integer) is
	
	begin
		if L = 1 then 
			T_IO.Put(Integer'Image(L) & " linea,");
		else 
			T_IO.Put(Integer'Image(L) & " lineas,");
		end if;
			
		if (Co) = 1 then 
			T_IO.Put(Integer'Image(Co) & " palabra,");
		else 
			T_IO.Put(Integer'Image(Co) & " palabras,");
		end if;
	
		if (Ca) = 1 then 
			T_IO.Put(Integer'Image(Ca) & " caracter");
		else 
			T_IO.Put_Line(Integer'Image(Ca) & " caracteres");
		end if;
	
		T_IO.New_Line;
	end ;
	
	Fichero: T_IO.File_Type;
	Txt: ASU.Unbounded_String;
	Posicion: Integer;
	P_Anterior: ASU.Unbounded_String;
	Txt2: ASU.Unbounded_String;
	Numesp:Integer:=0;
	Contador:Integer:=0;
	Valor_Paquete:Integer:=1;
	Lineas:Integer:=0;
	Caracteres:Integer:=0;
	N:Integer:=0;
	
	
begin
	begin

	if Ada.Command_Line.Argument(1) ="-t" and Ada.Command_Line.Argument(2) ="-f" then
	
		T_IO.Open(Fichero, T_IO.In_File, Ada.Command_Line.Argument(3)); --abre un fichero y lo lee
		
	elsif Ada.Command_Line.Argument(1) ="-f" and Ada.Command_Line.Argument(3) ="-t" then
	
		T_IO.Open(Fichero, T_IO.In_File, Ada.Command_Line.Argument(2)); 
	
	end if;
	exception
		when CONSTRAINT_ERROR =>
			T_IO.Open(Fichero, T_IO.In_File, Ada.Command_Line.Argument(2)); 
				
	end;
	
	
	while not T_IO.End_Of_File (Fichero) loop 
		
		
		Txt := ASU.To_Unbounded_String(T_IO.Get_Line(Fichero));
		Txt2:= ASU.Tail (Txt, ASU.Length(Txt));-- para  no usar el original
		
		
		Cuenta_Palabras.Trocear (Txt, Posicion, P_Anterior, Txt2, Numesp,
								Contador, Valor_Paquete, Fichero );
		
			
	
		Lineas := Lineas + 1;
		N:= ASU.Length(Txt); -- numero caracteres en cada linea
		Caracteres :=Caracteres+N; -- numero caracteres en total
		
	end loop;
	
	
	
	
	Escribir_Analisis (Lineas, Contador, Caracteres); 

	if Ada.Command_Line.Argument(3) = "-t" or Ada.Command_Line.Argument(1) = "-t" then
	
		T_IO.Put_Line("Palabras" );
		T_IO.Put_Line("--------" );
		Cuenta_Palabras.Palabras_Lista;
	end if;
	
	Ada.Text_IO.Close(Fichero);
		exception
		when ADA.IO_EXCEPTIONS.NAME_ERROR =>
			T_IO.Put_Line("Nombre de fichero no valido");
			T_IO.New_Line;
		when CONSTRAINT_ERROR =>
			T_IO.Put("");
		when ADA.IO_EXCEPTIONS.STATUS_ERROR =>
			T_IO.Put_Line("Comando no valido. Para contar palabras introduce '-t'.");
			T_IO.New_Line;
	
end Cuenta;