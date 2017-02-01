--Alfonso Nombela Moreno


package body Time_String is
	
	function Image (T: Ada.Calendar.Time) return String is
	begin
		return C_IO.Image(T, "%c");
	end Image;
	
	procedure Print_EP (EP:LLU.End_Point_Type) is
	
		N: Natural;
		A:ASU.Unbounded_String;
		S: ASU.Unbounded_String;
	begin
	
		A:=ASU.To_Unbounded_String(LLU.Image(EP));
		N := ASU.Index (A, ":");
		ASU.Tail (A, ASU.Length(A)-N-1); 
		S:=A;
		N := ASU.Index (S, ",");
		ASU.Head (S, N-1);
		N := ASU.Index (A, ":");
		ASU.Tail (A, ASU.Length(A)-N-2); 
		T_IO.Put_Line(ASU.To_String(S)&": "&ASU.To_String(A));
	
	end Print_EP;
	
 end Time_String;
