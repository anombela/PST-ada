--Alfonso Nombela Moreno

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Cuenta_Palabras;

procedure Trocea is
	package ASU renames Ada.Strings.Unbounded; 
	package T_IO renames Ada.Text_IO;

	Fichero: T_IO.File_Type;
	Txt: ASU.Unbounded_String;
	Posicion: Integer;
	P_Anterior: ASU.Unbounded_String;
	Txt2: ASU.Unbounded_String;
	Numesp:Integer:=0;
	Contador:Integer:=0;
	Valor_Paquete:Integer:=0;
	
begin

	T_IO.Put_Line("Escribir texto: ");
	Txt:= ASU.To_Unbounded_String(T_IO.Get_Line);
	Txt2:= ASU.Tail (Txt, ASU.Length(Txt));-- para  no usar el original
	
	Cuenta_Palabras.Trocear (Txt, Posicion, P_Anterior, Txt2, Numesp, Contador, Valor_Paquete,Fichero );
	
end Trocea;
