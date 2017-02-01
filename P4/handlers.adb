--Alfonso Nombela Moreno

package body Handlers is

	function Print_EP (EP:LLU.End_Point_Type)return ASU.Unbounded_String is----------------procedimiento nuevo
	
		
		N: Natural;
		A:ASU.Unbounded_String;
		S: ASU.Unbounded_String;
		Imagen:ASU.Unbounded_String;
	begin
	
		A:=ASU.To_Unbounded_String(LLU.Image(EP));
		N := ASU.Index (A, ":");
		ASU.Tail (A, ASU.Length(A)-N-1); 
		S:=A;
		N := ASU.Index (S, ",");
		ASU.Head (S, N-1);
		N := ASU.Index (A, ":");
		ASU.Tail (A, ASU.Length(A)-N-2); 
		Imagen:=ASU.To_Unbounded_String(ASU.To_String(S)&":"&ASU.To_String(A));
		return Imagen;
	end Print_EP;

	procedure Enviar_Mensaje (Mensaje_Tipo : CM.Message_Type;
						EP_H_Creat:LLU.End_Point_Type;
						Seq_N:CM.Seq_N_T;
						EP_H_Rsnd:LLU.End_Point_Type;
						EP_R_Creat:LLU.End_Point_Type;
						Nick:ASU.Unbounded_String;
						Confirm_Sent:Boolean;
						Text:ASU.Unbounded_String;
						EP_H_Reenvio:LLU.End_Point_Type) is
		L:Integer;
		Buffer:    aliased LLU.Buffer_Type(1024);
		Clase:ASU.Unbounded_String;

	begin
	
		LLU.Reset(Buffer);--resetea  para crear y mandar e mensaje inicial	
		CM.Message_Type'Output(Buffer'Access, Mensaje_Tipo);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Creat);
		CM.Seq_N_T'Output(Buffer'Access, Seq_N);
		LLU.End_Point_Type'Output(Buffer'Access, EP_H_Rsnd);
		if Mensaje_Tipo = CM.Init then
			LLU.End_Point_Type'Output(Buffer'Access, EP_R_Creat);---solo en init
		end if;
		ASU.Unbounded_String'Output(Buffer'Access, Nick);
		if Mensaje_Tipo = CM.Logout then
			Boolean'Output(Buffer'Access, Confirm_Sent);-- solo en logout
		end if;	
		if Mensaje_Tipo =CM.Writer then
			ASU.Unbounded_String'Output(Buffer'Access, Text);--solo en Writer
		end if;
		
		case Mensaje_Tipo is
			when CM.Init =>		
					Debug.Put("    FLOOD Init ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
					ASU.To_String(Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Nick),Pantalla.Verde);
			when CM.Reject =>		return;
			when CM.Confirm =>	
					Debug.Put("    FLOOD Confirm ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick),Pantalla.Verde);
			when CM.Writer =>		
					Debug.Put("    FLOOD Writer ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Handlers.Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
					ASU.To_String(Handlers.Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&
									" "&ASU.To_String(Text),Pantalla.Verde);
			when CM.Logout =>	
					Debug.Put("    FLOOD Logout ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&
									" "&Boolean'Image(Confirm_Sent),Pantalla.Verde);
		end case;
		
		Array_Vecinos:=Neighbors.Get_Keys(Lista_Vecinos);			
		L:=1;
		
		While Array_Vecinos(L)/=null loop
			if Array_Vecinos(L) /= EP_H_Reenvio then
				Debug.Put_Line("        send to: " & ASU.To_String(Print_EP(Array_Vecinos(L))),Pantalla.Verde);
				LLU.Send(Array_Vecinos(L), Buffer'Access); -- envia apodo y end point a server
			end if;
			L:=L+1;
		end loop;
		T_IO.New_Line;
		
	end Enviar_Mensaje;
	
	
	

	procedure Peer_Handler (From    : in     LLU.End_Point_Type;
						To      : in     LLU.End_Point_Type;
						P_Buffer: access LLU.Buffer_Type) is
      
		use type ASU.Unbounded_String;
		Mensaje_Tipo : CM.Message_Type;
		EP_H_Creat:LLU.End_Point_Type;
		Seq_N:CM.Seq_N_T;
		EP_H_Rsnd:LLU.End_Point_Type;
		EP_R_Creat:LLU.End_Point_Type;
		Nick:ASU.Unbounded_String;
		Buffer:    aliased LLU.Buffer_Type(1024);
		Success :Boolean;
		L:Integer;
		EP_H_Reenvio:LLU.End_Point_Type;--para almacenar el ep del que reenvia 
		Confirm_Sent:Boolean:=False;
		No_Reenviar:Boolean:=False;
		Text:Asu.Unbounded_String;
		Esta:Boolean:=False;
		Imagen_H: ASU.Unbounded_String;
		Imagen_R: ASU.Unbounded_String;
	begin
		--------RECIBE MENSAJE  --------------------------
		Mensaje_Tipo:=CM.Message_Type'Input(P_Buffer);
		if Mensaje_Tipo=CM.Init then
			
			EP_H_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:=CM.Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd:=LLU.End_Point_Type'Input(P_Buffer);
			EP_H_Reenvio:=EP_H_Rsnd;
			EP_R_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Nick :=ASU.Unbounded_String'Input(P_Buffer);
			
			A_M_EPs:=Latest_Msgs.Get_Keys(Lista_Mensajes);
			A_M_Valores:=Latest_Msgs.Get_Values(Lista_Mensajes);
			L:=1;
			While A_M_EPs(L)/=null loop
				if A_M_EPs(L)=EP_H_Creat and  Seq_N<=A_M_Valores(L) then
					No_Reenviar:=True;
				end if;
				L:=L+1;
			end loop;
				
			if EP_H_Creat = EP_H_Reenvio then 
				Neighbors.Put(Lista_Vecinos, EP_H_Creat, Ada.Calendar.Clock,Success);------------------NEIGHBORS
			end if;
			Latest_Msgs.Put(Lista_Mensajes,EP_H_Creat, Seq_N,Success);
			
			Debug.Put("RCV Init ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Nick),Pantalla.Verde);
						
			if not No_Reenviar and  Nick=Apodo then
				
				---------------------ENVIA MENSAJE REJECT----------------------------
				Debug.Put("    SEND  Reject ",Pantalla.Amarillo);
				Debug.Put_Line(ASU.To_String(Print_EP(EP_H)) &" "&ASU.To_String(Nick),Pantalla.Verde);
				
				LLU.Reset(Buffer);--resetea  para crear y mandar e mensaje inicial	
				Mensaje_Tipo:=CM.Reject;
				CM.Message_Type'Output(Buffer'Access, Mensaje_Tipo);
				LLU.End_Point_Type'Output(Buffer'Access, EP_H);
				ASU.Unbounded_String'Output(Buffer'Access, Apodo);
				LLU.Send(EP_R_Creat, Buffer'Access);
				
			end if;
			
			if not No_Reenviar then
				if Nick/=Apodo and EP_H_Creat = EP_H_Reenvio then
					Debug.Put_Line("    Añadimos a neighbors " & ASU.To_String(Print_EP(EP_H_Creat)),Pantalla.Verde);
				end if;
				Debug.Put_Line("    Añadimos a latest_messages " & ASU.To_String(Print_EP(EP_H_Creat)) &
										CM.Seq_N_T'Image(Seq_N),Pantalla.Verde);
			else
				Debug.Put("    NOFLOOD Init ",Pantalla.Amarillo);
				Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Nick),Pantalla.Verde);
				T_IO.New_Line;
			end if;
						
			if not No_Reenviar then
				------------------reenvia MENSAJE INICIAL--------Protocolo de  admision-------------
				Mensaje_Tipo:=CM.Init;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
			end if;	
			
		elsif Mensaje_Tipo=CM.Confirm then 
			----RECIVE MENSAJE CONFIRM---------------------
			EP_H_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:=CM.Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd:=LLU.End_Point_Type'Input(P_Buffer);
			EP_H_Reenvio:=EP_H_Rsnd;
			Nick :=ASU.Unbounded_String'Input(P_Buffer);
			
			A_M_EPs:=Latest_Msgs.Get_Keys(Lista_Mensajes);
			A_M_Valores:=Latest_Msgs.Get_Values(Lista_Mensajes);
			L:=1;
			While A_M_EPs(L)/=null loop
				if A_M_EPs(L)=EP_H_Creat and  Seq_N<=A_M_Valores(L) then
					No_Reenviar:=True;
					
				end if;
				L:=L+1;
			end loop;
			Debug.Put("RCV Confirm ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick),Pantalla.Verde);
			if not No_Reenviar then
				
				T_IO.Put_Line(ASU.To_String(Nick)&" ha entrado en el chat");	
				Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);
				Debug.Put_Line("    Añadimos a latest_messages " & ASU.To_String(Print_EP(EP_H_Creat)) &
										CM.Seq_N_T'Image(Seq_N),Pantalla.Verde);
			else
				Debug.Put("    NOFLOOD Confirm ",Pantalla.Amarillo);
				Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick),Pantalla.Verde);
				T_IO.New_Line;
			end if;
			if not No_Reenviar then
				-------------------reenvia MENSAJE Confirm--------Protocolo de  admision-------------
				Mensaje_Tipo:=CM.Confirm;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
				
			end if;
			Latest_Msgs.Put(Lista_Mensajes,EP_H_Creat, Seq_N,Success);	
			
		elsif Mensaje_Tipo=CM.Logout then 
		
			----------RECIVE MENSAJE LOGOUT----------------------------
			EP_H_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:=CM.Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd:=LLU.End_Point_Type'Input(P_Buffer);
			EP_H_Reenvio:=EP_H_Rsnd;
			Nick :=ASU.Unbounded_String'Input(P_Buffer);
			Confirm_Sent :=Boolean'Input(P_Buffer);
			
			A_M_EPs:=Latest_Msgs.Get_Keys(Lista_Mensajes);------------cambio
			A_M_Valores:=Latest_Msgs.Get_Values(Lista_Mensajes);
			L:=1;
			While A_M_EPs(L)/=null loop
				if A_M_EPs(L)=EP_H_Creat then
					Esta:=True;-----comprueba si no se ha borrado antes
				end if;
				if A_M_EPs(L)=EP_H_Creat and  Seq_N<=A_M_Valores(L) then
					No_Reenviar:=True;
				end if;
				L:=L+1;
			end loop;
			
			Debug.Put("RCV Logout ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&Boolean'Image(Confirm_Sent),Pantalla.Verde);
			if not No_Reenviar and Esta then
				
				Debug.Put_Line("    Borramos de latest_messages a "&  ASU.To_String(Print_EP(EP_H_Creat)),Pantalla.Verde); 	
				Debug.Put_Line("    Borramos de neighbors a  " & ASU.To_String(Print_EP(EP_H_Creat)),Pantalla.Verde);
				if Confirm_Sent =True then
					T_IO.Put_Line(ASU.To_String(Nick)&" ha abandonado el chat");
					Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);	
				end if;
			else
				
				Debug.Put("    NOFLOOD Logout ",Pantalla.Amarillo);
				Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&Boolean'Image(Confirm_Sent),Pantalla.Verde);
				T_IO.New_Line;
			end if;
			
			if not No_Reenviar and Esta then
				------------------reenvia MENSAJE Logout--------Protocolo de  admision---------
				Mensaje_Tipo:=CM.Logout;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
				
				if EP_H_Creat = EP_H_Reenvio then 
					Neighbors.Delete(Lista_Vecinos, EP_H_Creat,Success);------------------NEIGHBORS
				end if;
				
				
				Latest_Msgs.Delete(Lista_Mensajes, EP_H_Creat,Success);
				
			end if;
			
		elsif Mensaje_Tipo=CM.Writer then 
			----------------RECIVE MENSAJE WRITER---------------
			EP_H_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:=CM.Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd:=LLU.End_Point_Type'Input(P_Buffer);
			EP_H_Reenvio:=EP_H_Rsnd;
			Nick :=ASU.Unbounded_String'Input(P_Buffer);
			Text :=ASU.Unbounded_String'Input(P_Buffer);
			
			A_M_EPs:=Latest_Msgs.Get_Keys(Lista_Mensajes);
			A_M_Valores:=Latest_Msgs.Get_Values(Lista_Mensajes);
			L:=1;
			While A_M_EPs(L)/=null loop
				if A_M_EPs(L)=EP_H_Creat and  Seq_N<=A_M_Valores(L) then
					No_Reenviar:=True;
				end if;
				L:=L+1;
			end loop;
			
			Debug.Put("RCV Writer ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&ASU.To_String(Text),Pantalla.Verde);
			if not No_Reenviar then
				
				T_IO.Put_Line(ASU.To_String(Nick)&": "&ASU.To_String(Text));
				Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);
				Debug.Put_Line("    Añadimos a latest_messages " & ASU.To_String(Print_EP(EP_H_Creat)) &
										CM.Seq_N_T'Image(Seq_N),Pantalla.Verde);
			else
				Debug.Put("    NOFLOOD Writer ",Pantalla.Amarillo);
				Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick),Pantalla.Verde);
				T_IO.New_Line;
			end if;
			
			if not No_Reenviar then
				------------------reenvia MENSAJE wRITER-------------
				Mensaje_Tipo:=CM.Writer;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
				
			end if;
			Latest_Msgs.Put(Lista_Mensajes,EP_H_Creat, Seq_N,Success);	
			
		end if;
		
	end Peer_Handler;

end Handlers;