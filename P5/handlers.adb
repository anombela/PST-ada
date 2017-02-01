--Alfonso Nombela Moreno

package body Handlers is

	procedure Free is new Ada.Unchecked_Deallocation (LLU.Buffer_Type , CM.Buffer_A_T);--para liberar memoria
	
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


	function Mess_Id_To_String ( Mess: Mess_Id_T) return String is
	begin
	
		return ASU.To_String(Print_EP(Mess.EP)) &","&CM.Seq_N_T'Image(Mess.Seq);
		
	end Mess_Id_To_String;
	
	
	function Destination_To_String ( Des: Destinations_T) return String is
	L:Integer:=1;
	C:ASU.Unbounded_String;
	T:ASU.Unbounded_String;
	Max:Integer:=10;
	begin
		
		while L <=Max loop
			if Des(L).Ep = null then
				C:=ASU.To_Unbounded_String("-");
			else
				C:= ASU.To_Unbounded_String (ASU.To_String(Print_EP(Des(L).Ep)) &": ret="&Natural'Image(Des(L).Retries));
			end if;
			if L=1 then
				T:=ASU.To_Unbounded_String("["&ASU.To_String(C));
			elsif L=Max then
				T:=ASU.To_Unbounded_String(ASU.To_String(T)&"], ["&ASU.To_String(C)&"]");
			else
				T:=ASU.To_Unbounded_String(ASU.To_String(T)&"], ["&ASU.To_String(C));
			end if;
			L:=L+1;
		end loop;
		return ASU.To_String(T);
		
	end Destination_To_String;
	------------------------------
	 function "=" (K1, K2: Mess_Id_T) return Boolean is 
	 begin 
		if LLU.Image(K1.EP) = LLU.Image(K2.EP) and CM.Seq_N_T'Image(K1.Seq) = CM.Seq_N_T'Image(K2.Seq) then
			return True;	
		else 
			return False;
		end if;
	end "=";
	
	 function "<" (K1, K2: Mess_Id_T) return Boolean is 
	 begin 
		if LLU.Image(K1.EP) < LLU.Image(K2.EP) then 
			return True;
		elsif LLU.Image(K1.EP) = LLU.Image(K2.EP) and CM.Seq_N_T'Image(K1.Seq) < CM.Seq_N_T'Image(K2.Seq) then
			return True;	
		else 
			return False;
		end if;
	end "<";
	 function ">" (K1, K2: Mess_Id_T) return Boolean is 
	 begin 
		if LLU.Image(K1.EP) > LLU.Image(K2.EP) then 
			return True;
		elsif LLU.Image(K1.EP) = LLU.Image(K2.EP) and CM.Seq_N_T'Image(K1.Seq) > CM.Seq_N_T'Image(K2.Seq) then
			return True;	
		else 
			return False;
		end if;
	end ">";
------------------------------------------------
	
	function Val_To_String (Val: Value_T) return String is
	begin
	
		return ASU.To_String(Print_EP(Val.EP_H_Creat)) &":"&CM.Seq_N_T'Image(Val.Seq_N);
		
	end Val_To_String;
	
-----------------------------
	function "=" (K1, K2:Ada.Calendar.Time) return Boolean is 
	begin 
		
		--if K1= K2 then
		if Time_String.Image2(K1) = Time_String.Image2(K2) then
			return True;	
		else 
			return False;
		end if;
	end "=";
	
	function "<" (K1, K2: Ada.Calendar.Time) return Boolean is 
	begin 
		--if K1 < K2 then 
		if Time_String.Image2(K1) < Time_String.Image2(K2) then 
			return True;
		else 
			return False;
		end if;
	end "<";
	function ">" (K1, K2: Ada.Calendar.Time) return Boolean is 
	begin 
		--if K1 > K2 then 
		if Time_String.Image2(K1) > Time_String.Image2(K2) then 
			return True;
		else 
			return False;
		end if;
	end ">";
------------------------------------------------
	
	procedure Enviar_Mensaje (Mensaje_Tipo : CM.Message_Type;
						EP_H_Creat:LLU.End_Point_Type;
						Seq_N:CM.Seq_N_T;
						EP_H_Rsnd:LLU.End_Point_Type;
						EP_R_Creat:LLU.End_Point_Type;
						Nick:ASU.Unbounded_String;
						Confirm_Sent:Boolean;
						Text:ASU.Unbounded_String;
						EP_H_Reenvio:LLU.End_Point_Type) is
		L,Z,S:Integer;
		Clase:ASU.Unbounded_String;
		Hora_Retr,Hora_Actual,Hora:Ada.Calendar.Time;
		Hay_Vecinos:Boolean;
		Max_Vecinos:Integer:=10;
	begin
		
		CM.P_Buffer_Handler := new LLU.Buffer_Type(1024);-----------------
		
		CM.Message_Type'Output(CM.P_Buffer_Handler, Mensaje_Tipo);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
		CM.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
		LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Rsnd);
		if Mensaje_Tipo = CM.Init then
			LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_R_Creat);---solo en init
		end if;
		ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
		if Mensaje_Tipo = CM.Logout then
			Boolean'Output(CM.P_Buffer_Handler, Confirm_Sent);-- solo en logout
		end if;	
		if Mensaje_Tipo =CM.Writer then
			ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Text);--solo en Writer
		end if;
		
		case Mensaje_Tipo is
			when CM.Init =>		
					Debug.Put("    FLOOD Init ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
					ASU.To_String(Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Nick),Pantalla.Verde);
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
			when others =>		return;
		end case;
		
			
		
		Array_Vecinos:=Neighbors.Get_Keys(Lista_Vecinos);	
		
		Z:=1;
		while Z<=Max_Vecinos loop---- asigna todos los valores a null antes de procesarlo por si quedaba algo
			Mensajes_Valor(Z).Ep:=null;
			Z:=Z+1;
		end loop;
		
		L:=1;
		Hay_Vecinos:=False;
		While Array_Vecinos(L)/=null loop
		
			if Array_Vecinos(L) /= EP_H_Reenvio then
				
				Hay_Vecinos:=True;
				Debug.Put_Line("        send to: " & ASU.To_String(Print_EP(Array_Vecinos(L))),Pantalla.Verde);
				LLU.Send(Array_Vecinos(L),CM.P_Buffer_Handler); -- envia apodo y end point a server
			
				S:=1;
				while Mensajes_Valor(S).Ep/=null  loop
					S:=S+1;
				end loop;
	
				Mensajes_Valor(S).Ep:=Array_Vecinos(L);
				Mensajes_Valor(S).Retries:=0;
				
			end if;
			
			L:=L+1;
		end loop;
		
		
		
		
		 if Hay_Vecinos then
		
			---METER EL MENSAJE EN SENDER_DEST----
		
			Mensaje_Clave.EP:=EP_H_Creat;
			Mensaje_Clave.Seq:=Seq_N;
			Sender_Dests.Put(Ack_Mensajes,Mensaje_Clave,Mensajes_Valor);
			Debug.Put_Line("    Añadimos a Sender_Dests " & ASU.To_String(Print_EP(EP_H_Creat)) &
											CM.Seq_N_T'Image(Seq_N),Pantalla.Azul);
											
			---METER EL MENSAJE EN SENDER_BUFFERING----
			-----------------------------------------------------------		
			Value.EP_H_Creat:=EP_H_Creat;
			Value.Seq_N:=Seq_N;
			Value.P_Buffer:= CM.P_Buffer_Handler;
			Hora_Actual:=Ada.Calendar.Clock;
			Hora:=Hora_Actual;
			Hora_Retr:=Hora+Plazo_Retransmision;---HORA A LA QUE SE RETRANSMITIRA EL MENSAJE
			---------------------------------------
			--Debug.Put_Line(Time_String.Image2(Hora_Actual),Pantalla.Blanco);
			--Debug.Put_Line(Time_String.Image2(Hora),Pantalla.Blanco);
			--Debug.Put_Line(Time_String.Image2(Hora_Retr),Pantalla.Blanco);
			-------------------------------------
			Timed_Handlers.Set_Timed_Handler (Hora_Retr, Manejador_T'Access); 
			Sender_Buffering.Put(Buffer_Mensajes,Hora_Retr,Value);
			Debug.Put_Line("    Añadimos a Sender_Buffering " & ASU.To_String(Print_EP(EP_H_Creat)) &
											CM.Seq_N_T'Image(Seq_N)&Time_String.Image2(Hora_Retr),Pantalla.Azul);
			
			
			Debug.Put_Line("    Programammos renvio:  " &Time_String.Image2(Hora_Retr),Pantalla.Gris_Oscuro);
			
			
		end if;
		T_IO.New_Line;
		
	end Enviar_Mensaje;
	
	Procedure Enviar_Ack(EP_H_ACKer: out LLU.End_Point_Type;
					EP_H_Creat:LLU.End_Point_Type;
					Seq_N:CM.Seq_N_T;
					EP_H_Rsnd:LLU.End_Point_Type) is
	
		Buffer:    aliased LLU.Buffer_Type(1024);
		
	begin
	
		LLU.Reset(Buffer);
		CM.Message_Type'output(Buffer'access,CM.Ack);
		EP_H_ACKer:=EP_H;
		LLU.End_Point_Type'output(Buffer'access,EP_H_ACKer);                           
		LLU.ENd_POint_Type'Output(Buffer'access,EP_H_Creat);
		CM.Seq_N_T'output(Buffer'access,Seq_N);
		LLU.Send(EP_H_Rsnd,Buffer'access);           

		Debug.Put("    SEND Ack ",Pantalla.Amarillo);
		Debug.Put_Line("from "&ASU.To_String(Print_EP(EP_H_ACKer)) &" to "&
			ASU.To_String(Print_EP(EP_H_Rsnd))&". creador:"&ASU.To_String(Print_EP(EP_H_Creat))&" Seq:"&CM.Seq_N_T'Image(Seq_N),Pantalla.Verde);
			
			T_IO.New_Line;
	
	end Enviar_Ack;
	
	procedure Peer_Handler (From    : in     LLU.End_Point_Type;
						To      : in     LLU.End_Point_Type;
						P_Buffer: access LLU.Buffer_Type) is
      
		use type ASU.Unbounded_String;
		Mensaje_Tipo : CM.Message_Type;
		Seq_N:CM.Seq_N_T;
		EP_H_Creat,EP_H_ACKer,EP_H_Rsnd,EP_R_Creat:LLU.End_Point_Type;
		Nick:ASU.Unbounded_String;
		Buffer:    aliased LLU.Buffer_Type(1024);
		Success :Boolean;
		L:Integer;
		EP_H_Reenvio:LLU.End_Point_Type;--para almacenar el ep del que reenvia 
		No_Reenviar,M_Futuro,Esta,Confirm_Sent:Boolean:=False;
		Text:Asu.Unbounded_String;
		Imagen_H,Imagen_R: ASU.Unbounded_String;
		Z:Integer;
		Vacio,Borrado:Boolean;
		
		
	begin
		--Debug.Put(Time_String.Image2(Ada.Calendar.Clock),Pantalla.Gris_Oscuro);-------------------muestra hora
		--------RECIBE MENSAJE  --------------------------
		
		Mensaje_Tipo:=CM.Message_Type'Input(P_Buffer);
		if Mensaje_Tipo=CM.Init then
			
			EP_H_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:=CM.Seq_N_T'Input(P_Buffer);
			EP_H_Rsnd:=LLU.End_Point_Type'Input(P_Buffer);
			EP_H_Reenvio:=EP_H_Rsnd;
			EP_R_Creat:=LLU.End_Point_Type'Input(P_Buffer);
			Nick :=ASU.Unbounded_String'Input(P_Buffer);
			
			Debug.Put("RCV Init ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Nick),Pantalla.Verde);
			
			A_M_EPs:=Latest_Msgs.Get_Keys(Lista_Mensajes);
			A_M_Valores:=Latest_Msgs.Get_Values(Lista_Mensajes);
			L:=1;
			While A_M_EPs(L)/=null loop
				if A_M_EPs(L)=EP_H_Creat and  Seq_N<=A_M_Valores(L) then
				
					No_Reenviar:=True;
					
				elsif A_M_EPs(L)=EP_H_Creat and Seq_N>= A_M_Valores(L)+2 then 
					Debug.Put_Line("MENSAJE FUTURO",Pantalla.magenta);
					M_Futuro:=True;
					
				end if;
				L:=L+1;
			end loop;
			if not M_Futuro then
				if not No_Reenviar then
			
					if Nick/=Apodo and EP_H_Creat = EP_H_Reenvio then
						Debug.Put_Line("    Añadimos a neighbors " & ASU.To_String(Print_EP(EP_H_Creat)),Pantalla.Azul);
						Neighbors.Put(Lista_Vecinos, EP_H_Creat, Ada.Calendar.Clock,Success);
					end if;
				
					Debug.Put_Line("    Añadimos a latest_messages " & ASU.To_String(Print_EP(EP_H_Creat)) &
										CM.Seq_N_T'Image(Seq_N),Pantalla.Azul);
					
					Latest_Msgs.Put(Lista_Mensajes,EP_H_Creat, Seq_N,Success);
					
				else
					Debug.Put("    NOFLOOD Init ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
								ASU.To_String(Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Nick),Pantalla.Verde);
					T_IO.New_Line;
				end if;	
			
						
				
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
			
				Enviar_Ack(EP_H_ACKer,EP_H_Creat,Seq_N,EP_H_Rsnd);---- envia el asentimiento
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
				elsif A_M_EPs(L)=EP_H_Creat and Seq_N>= A_M_Valores(L)+2 then 
					Debug.Put_Line("MENSAJE FUTURO",Pantalla.magenta);
					M_Futuro:=True;	
				end if;
				L:=L+1;
			end loop;
			Debug.Put("RCV Confirm ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick),Pantalla.Verde);
			if not M_Futuro then			
				if not No_Reenviar then
				
					T_IO.Put_Line(ASU.To_String(Nick)&" ha entrado en el chat");	
				
					Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);
					Debug.Put_Line("    Añadimos a latest_messages " & ASU.To_String(Print_EP(EP_H_Creat)) &
										CM.Seq_N_T'Image(Seq_N),Pantalla.Azul);
										
				
					Latest_Msgs.Put(Lista_Mensajes,EP_H_Creat, Seq_N,Success);	
									
				else
					Debug.Put("    NOFLOOD Confirm ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick),Pantalla.Verde);
					T_IO.New_Line;
				end if;
			
				Enviar_Ack(EP_H_ACKer,EP_H_Creat,Seq_N,EP_H_Rsnd);---- envia el asentimiento	
				
			end if;
			
			if not No_Reenviar then
				-------------------reenvia MENSAJE Confirm--------Protocolo de  admision-------------
				Mensaje_Tipo:=CM.Confirm;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
				
			end if;
			
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
				elsif A_M_EPs(L)=EP_H_Creat and Seq_N>=A_M_Valores(L)+ 2 then 
					
					M_Futuro:=True;
				end if;
				L:=L+1;
			end loop;
			
			Debug.Put("RCV Logout ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&Boolean'Image(Confirm_Sent),Pantalla.Verde);
			if not M_Futuro then			
				if Esta then			
					if EP_H_Creat = EP_H_Reenvio then 
						Debug.Put_Line("    Borramos de neighbors a  " & ASU.To_String(Print_EP(EP_H_Creat)),Pantalla.Azul);
						Neighbors.Delete(Lista_Vecinos, EP_H_Creat,Success);------------------NEIGHBORS
					end if;
				
					Debug.Put_Line("    Borramos de latest_messages a "&  ASU.To_String(Print_EP(EP_H_Creat)),Pantalla.Azul); 	
					Latest_Msgs.Delete(Lista_Mensajes, EP_H_Creat,Success);-- no borra si es mensaje del futuro
					
						
						
				if Confirm_Sent =True then
					
					T_IO.Put_Line(ASU.To_String(Nick)&" ha abandonado el chat");
					
					Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);	
				end if;		
			end if;	
			
				Enviar_Ack(EP_H_ACKer,EP_H_Creat,Seq_N,EP_H_Rsnd);---- envia el asentimiento	
				
			end if;	
			
			
			if not No_Reenviar and Esta then
				------------------reenvia MENSAJE Logout--------Protocolo de  admision---------
				Mensaje_Tipo:=CM.Logout;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
				
			else
				
				Debug.Put("    NOFLOOD Logout ",Pantalla.Amarillo);
				Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&Boolean'Image(Confirm_Sent),Pantalla.Verde);
				T_IO.New_Line;
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
					
					
				elsif A_M_EPs(L)=EP_H_Creat and Seq_N>=A_M_Valores(L) +2 then 
					

					M_Futuro:=True;
			
				end if;
				L:=L+1;
			end loop;
			
			Debug.Put("RCV Writer ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&ASU.To_String(Text),Pantalla.Verde);
			if not M_Futuro then
			
				if not No_Reenviar then
				
					T_IO.Put_Line(ASU.To_String(Nick)&": "&ASU.To_String(Text));
				
					Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);
					Debug.Put_Line("    Añadimos a latest_messages " & ASU.To_String(Print_EP(EP_H_Creat)) &
											CM.Seq_N_T'Image(Seq_N),Pantalla.Azul);
				
					
				
					Latest_Msgs.Put(Lista_Mensajes,EP_H_Creat, Seq_N,Success);

				else
					Debug.Put("    NOFLOOD Writer ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
								ASU.To_String(Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Nick)&" "&ASU.To_String(Text),Pantalla.Verde);
					T_IO.New_Line;
				end if;
			
			
				
				Enviar_Ack(EP_H_ACKer,EP_H_Creat,Seq_N,EP_H_Reenvio);---- envia el asentimiento	
			end if;
			
			if not No_Reenviar then
				------------------reenvia MENSAJE wRITER-------------
				Mensaje_Tipo:=CM.Writer;
				EP_H_Rsnd:= EP_H;
				Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text,EP_H_Reenvio);
				
			end if;
			
			
		elsif Mensaje_Tipo=CM.Ack then 
			EP_H_ACKer := LLU.End_Point_Type'Input(P_Buffer);
			EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
			Seq_N:= CM.Seq_N_T'Input(P_Buffer);
			
			
			Debug.Put("RCV Ack ",Pantalla.Amarillo);
			Debug.Put_Line("from "&ASU.To_String(Print_EP(EP_H_ACKer)) &" to "&
				ASU.To_String(Print_EP(EP_H))&". creador:"&ASU.To_String(Print_EP(EP_H_Creat)&":"&CM.Seq_N_T'Image(Seq_N)),Pantalla.Verde);
			
			Mensaje_Clave.EP:=EP_H_Creat;
			Mensaje_Clave.Seq:=Seq_N;
			
			Sender_Dests.Get(Ack_Mensajes,Mensaje_Clave,Mensajes_Valor,Success);
			Z:=1;
			Vacio:=True;
			Borrado:=False;
			while Z <=10 loop
				 if Mensajes_Valor(Z).EP = EP_H_ACKer then
					Borrado:=True;       --esto significa que ha pasado por aqui y comprueba si es ack repe
					Mensajes_Valor(Z).EP := null;
					
					Debug.Put_Line("    Modificamos de Sender_Dests el mensaje creado por "&  ASU.To_String(Print_EP(Mensaje_Clave.EP))&" Seq:"&CM.Seq_N_T'Image(Seq_N),Pantalla.Azul); 
					Sender_Dests.Put(Ack_Mensajes,Mensaje_Clave,Mensajes_Valor);
				end if;
				Z:=Z+1;
			end loop;
			Z:=1;
			while Z <=10 loop
					
				if	Mensajes_Valor(Z).EP /= null  then
					Vacio :=False;    --SIGNIFICA QUE TODAVIA QUEDA ALGUN ASENTIMIENTO PENDIENTE DEL MENSAJE
					
				end if;
			
				Z:=Z+1;
			end loop;
			
			if Vacio then
				Debug.Put_Line("    Borramos de Sender_Dests el mensaje creado por "&  ASU.To_String(Print_EP(Mensaje_Clave.EP))&" Seq:"&CM.Seq_N_T'Image(Seq_N),Pantalla.Azul); 	
				Sender_Dests.Delete(Ack_Mensajes,Mensaje_Clave,Success);
				T_IO.New_Line;
				
			elsif  not Borrado then 
				Debug.Put_Line("    Ack repetido ",Pantalla.Azul);
			end if;
			T_IO.New_Line;

		end if;
		
	end Peer_Handler;
	
	procedure Manejador_T (Time: Ada.Calendar.Time) is
		T_Valor:Value_T;  
		T_Success:Boolean;
		T_Mens_Clave:Mess_Id_T;
		T_Mens_Valor:Destinations_T;
		J:Integer:=1;
		T_Borrar:Boolean:=True;
		T_Hora_Retr,T_Hora_Actual:Ada.Calendar.Time;
		Max_Destinos:Integer:=10;
		Max_Retr:Integer:=10;
		Debug_Act:Boolean;
		
		
		
		 
	
	begin
		--Debug.Put(Time_String.Image2(Ada.Calendar.Clock),Pantalla.Gris_Oscuro);-------------------------------muestra hora
		
		
		Debug.Put_Line("Entramos en manejador (RE)",Pantalla.Blanco);
		Sender_Buffering.Get(Buffer_Mensajes,Time,T_Valor,T_Success);
		--Debug.Put_Line(Boolean'Image(T_Success),Pantalla.Blanco);---escribe si sucede o no
		Debug.Put_Line("    RE Borramos de Sender_Buffering el mensaje de hora "&Time_String.Image2(Time),Pantalla.Azul); 
		
		if not T_Success then
			Error:=True;
			Debug.Put_Line("    RE No encontrado "&Time_String.Image2(Time),Pantalla.Azul);
			--return;
		end if;
		
		T_IO.New_Line;
		Sender_Buffering.Delete(Buffer_Mensajes,Time,T_Success);--se borra por que esa hora ya no sirve
		 
		T_Mens_Clave.EP:=T_Valor.EP_H_Creat;
		T_Mens_Clave.Seq:=T_Valor.Seq_N;
		
		Sender_Dests.Get(Ack_Mensajes,T_Mens_Clave,T_Mens_Valor,T_Success);
		T_Borrar:=True;
		 while J <=Max_Destinos loop
		 -----------------------------------------------------------
			if  T_Mens_Valor(J).Retries >=Max_Retr  and EP_Max=null then-- nul por solo el primero que completa las retransmisiones
			
				Max_Retransmisiones:=True;
				Seq_Max:=T_Mens_Clave.Seq;
				EP_Max:=T_Mens_Clave.EP;
		
			end if;
		------------------------------------------
			
			if T_Mens_Valor(J).EP /= null and T_Mens_Valor(J).Retries <Max_Retr then
				
				T_Borrar:=False;
				LLU.Send(T_Mens_Valor(J).EP,T_Valor.P_Buffer);
			
				T_Mens_Valor(J).Retries:= T_Mens_Valor(J).Retries + 1;
				
				Debug.Put("Retransmite("& Time_String.Image2(Time)& ") ",Pantalla.Amarillo);
					Debug.Put_Line("de: "&ASU.To_String(Handlers.Print_EP(T_Mens_Clave.Ep)) & ", Seq:"&CM.Seq_N_T'Image(T_Mens_Clave.Seq) &", para: "& 
					ASU.To_String(Handlers.Print_EP(T_Mens_Valor(J).EP))&", Num:"&Integer'Image(T_Mens_Valor(J).Retries),Pantalla.Verde);
		
			end if;
		 
			J:=J+1;
		 end loop;
		
		if T_Borrar then
		 ----------------------------Borramos si no quedaran entradas, o quede algun end point con retries >10 
			Debug.Put_Line("    RE Borramos de Sender_Dests el mensaje creado por "&  ASU.To_String(Print_EP(T_Mens_Clave.EP))&
												" Seq:"&CM.Seq_N_T'Image(T_Valor.Seq_N)&" (si esta).",Pantalla.Azul); 	
			Sender_Dests.Delete(Ack_Mensajes,T_Mens_Clave,T_Success);
			
			Free(T_Valor.P_Buffer);--si se elimina por completo esto libera la memoria qu eapuntaba el buufer
			Debug.Put_Line("    RE Libera memoria: " &Time_String.Image2(Time),Pantalla.Gris_Oscuro);--
			
			-------------------------------------------------
			Debug_Act:=Debug.Get_Status;
			if Debug_Act then
				T_IO.New_Line;
			end if;
			-----------------------------
			
		else
			
			Debug.Put_Line("    RE Añadimos a Sender_Dests " & ASU.To_String(Print_EP(T_Mens_Clave.EP)) &
											CM.Seq_N_T'Image(T_Mens_Clave.Seq),Pantalla.Azul);
			Sender_Dests.Put(Ack_Mensajes,T_Mens_Clave,T_Mens_Valor);
			
			T_Hora_Actual:=Ada.Calendar.Clock;
			
			T_Hora_Retr:=T_Hora_Actual+Plazo_Retransmision;
			Timed_Handlers.Set_Timed_Handler (T_Hora_Retr, Manejador_T'Access);
			
			---------------------------------------
			--Debug.Put_Line("RE: "&Time_String.Image2(T_Hora_Actual),Pantalla.Blanco);
	
			--Debug.Put_Line("RE: "&Time_String.Image2(T_Hora_Retr),Pantalla.Blanco);
			------------------------------------
			
			
		
			
			Debug.Put_Line("    RE Añadimos a Sender_Buffering " & ASU.To_String(Print_EP(T_Mens_Clave.EP)) &
											CM.Seq_N_T'Image(T_Mens_Clave.Seq)&Time_String.Image2(T_Hora_Retr),Pantalla.Azul);
			Sender_Buffering.Put(Buffer_Mensajes,T_Hora_Retr,T_Valor);---CREA EL NUEVO MENSAJE  CON LA NUEVA HORA DE RETRANSMITIR
			
			
			Debug.Put_Line("    RE Programamos renvio:  " &Time_String.Image2(T_Hora_Retr),Pantalla.Gris_Oscuro);--
		end if;
		
	end Manejador_T;
	
	
	

end Handlers;
