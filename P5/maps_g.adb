--Alfonso Nombela Moreno

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Ada.Strings.Unbounded;

package body Maps_G is

	package ASU  renames Ada.Strings.Unbounded;
	package T_IO renames Ada.Text_IO;
	
	procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


	procedure Get (M       : Map;
				Key     : in  Key_Type;
				Value   : out Value_Type;
				Success : out Boolean) is
		P_Aux : Cell_A;
	begin
		P_Aux := M.P_First;
		Success := False;
		while not Success and P_Aux /= null Loop
			if P_Aux.Key = Key then
				Value := P_Aux.Value;
				Success := True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;
	end Get;


	procedure Put (M     : in out Map;
				Key   : Key_Type;
				Value : Value_Type;
				Success : out Boolean) is
			
		P_Aux : Cell_A;
		Found : Boolean;
		
	begin
		-- Si ya existe Key, cambiamos su Value
		P_Aux := M.P_First;
		Found := False;
		Success := False;
		while not Found and P_Aux /= null loop
			if P_Aux.Key = Key then
				P_Aux.Value := Value;
				Found := True;
				Success :=True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;

		-- Si no hemos encontrado Key añadimos al principio
		if not Found then
			if M.Length < Max_Length then
				M.P_First := new Cell'(Key, Value, M.P_First,null);
				if M.P_First.Next = null then
					M.P_Anterior:= M.P_First;
				else
					M.P_First.Next.Previous := M.P_First;
				end if;
				M.Length := M.Length + 1;
				Success :=True;
			end if;
		end if;
	end Put;



	procedure Delete (M      : in out Map;
				Key     : in  Key_Type;
				Success : out Boolean) is
				
		P_Current  : Cell_A;
		P_Previous : Cell_A;
	begin
		Success := False;
		P_Previous := null;
		P_Current  := M.P_First;
		while not Success and P_Current /= null  loop
			if P_Current.Key = Key then
				Success := True;
				M.Length := M.Length - 1;
				
				-----ahora  veremos 3 borrados posibles -----
				if P_Previous /= null and P_current.Next = null then
					P_Previous.Next := P_Current.Next;
					--Free(P_current);-------
				end if;
				
				 if P_Previous /= null and P_Current.Next /= null then
					 P_Previous.Next:= P_Current.Next;
					P_Current.Next.Previous := P_Previous;
					--Free(P_Current);
				end if;
				
				if M.P_First = P_Current then
					M.P_First := M.P_First.Next;
					M.P_Anterior := M.P_First;
				end if;
				Free (P_Current);
			else
				P_Previous := P_Current;
				P_Current := P_Current.Next;
			end if;
		end loop;

	end Delete;

	function Get_Keys (M: Map) return Keys_array_Type is
	
		P_Aux: Cell_A;
		Keys: Keys_array_Type;
		Posicion: Natural:=1;
	begin
                P_Aux:=M.P_First;
               
                while P_Aux /= null loop
                        keys(Posicion):= P_Aux.key;
                        P_Aux:= P_Aux.Next;
                        Posicion:= Posicion+1;
                end loop;
		
                while Posicion<= Max_Length loop--bucle que rellena con Keys nulos
                        keys(Posicion):= Null_Key;
                        Posicion:=Posicion+1;
		end loop;      
		
		return keys;
        end Get_keys;
	
	
	function Get_Values (M: Map) return Values_array_Type is
	
		P_Aux: Cell_A;
		Values: Values_array_Type;
		Posicion: Natural:= 1;
	begin
                P_Aux:=M.P_First;
               
                while P_Aux /= null loop
                        Values(Posicion):= P_Aux.Value;
                        P_Aux:= P_Aux.Next;
                        Posicion:= Posicion+1;
                end loop;
		
                while Posicion<= Max_Length loop
                        Values(Posicion):= Null_Value;--bucle que rellena con valores nulos
                        Posicion:=Posicion+1;
                end loop;      
		
		return Values;
        end Get_Values;
	
	function Map_Length (M : Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

	procedure Print_Map (M : Map) is
		P_Aux : Cell_A;
		N: Natural;
		A:ASU.Unbounded_String;
		S: ASU.Unbounded_String;
	begin
		P_Aux := M.P_First;

		while P_Aux /= null loop
		
			A:=ASU.To_Unbounded_String(Key_To_String(P_Aux.Key));
			N := ASU.Index (A, ":");
			ASU.Tail (A, ASU.Length(A)-N-1); 
			S:=A;
			N := ASU.Index (S, ",");
			ASU.Head (S, N-1);
			N := ASU.Index (A, ":");
			ASU.Tail (A, ASU.Length(A)-N-2); 
			Ada.Text_IO.Put_Line ("              [ ("&ASU.To_String(S)&":"&ASU.To_String(A)&
										"), " & Value_To_String(P_Aux.Value)&" ]");
			P_Aux := P_Aux.Next;
		end loop;
	end Print_Map;

end Maps_G;
