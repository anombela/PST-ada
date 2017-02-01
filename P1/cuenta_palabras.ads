--Alfonso Nombela Moreno

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Exceptions;
with Lista;

package Cuenta_Palabras is

	
	procedure Escribe_Palabras (C: in out Integer;
						      T:  in out Ada.Strings.Unbounded.Unbounded_String);
	
	procedure Numero (C2: in out Integer;
						      N: in out Integer);
						      
	procedure Trocear (T1: in out Ada.Strings.Unbounded.Unbounded_String;
					P:  out Integer;
					P_A: in out Ada.Strings.Unbounded.Unbounded_String;
					T2: in out Ada.Strings.Unbounded.Unbounded_String;
					Ne: in out Integer;
					Con: in out Integer;
					Valor:in Integer;
					Fich: in out Ada.Text_IO.File_Type);
					
	procedure Palabras_Lista;
					
	
end Cuenta_Palabras; 
