--Alfonso Nombela Moreno

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;
with Chat_Messages;
with Ada.Exceptions;
with Handlers;
with Ada.Calendar;
with Pantalla;
with Debug;
with Prompt;


procedure Chat_Peer is

	package LLU renames Lower_Layer_UDP;
	package T_IO renames Ada.Text_IO;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	use type CM.Seq_N_T;
	use Type LLU.End_Point_Type;
	
	procedure Enviar_Mensaje (Mensaje_Tipo : CM.Message_Type;
						EP_H_Creat:LLU.End_Point_Type;
						Seq_N:CM.Seq_N_T;
						EP_H_Rsnd:LLU.End_Point_Type;
						EP_R_Creat:LLU.End_Point_Type;
						Nick:ASU.Unbounded_String;
						Confirm_Sent:Boolean;
						Text:ASU.Unbounded_String) is
		L:Integer;
		Buffer:    aliased LLU.Buffer_Type(1024);
		Success :Boolean;
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
		if Mensaje_Tipo/=CM.Logout then----- en todos menos en logout
			Debug.Put_Line("Añadimos a latest_messages " & ASU.To_String(Handlers.Print_EP(EP_H_Creat)) &
										CM.Seq_N_T'Image(Seq_N),Pantalla.Verde);
		end if;
		
		case Mensaje_Tipo is
			when CM.Init =>		
					Debug.Put("FLOOD Init ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Handlers.Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
					ASU.To_String(Handlers.Print_EP(EP_H_Rsnd))&" ... "&ASU.To_String(Handlers.Apodo),Pantalla.Verde);
			when CM.Reject =>		return;
			when CM.Confirm =>	
					Debug.Put("FLOOD Confirm ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Handlers.Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
							ASU.To_String(Handlers.Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Handlers.Apodo),Pantalla.Verde);
			when CM.Writer =>		
					Debug.Put("FLOOD Writer ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Handlers.Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
					ASU.To_String(Handlers.Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Handlers.Apodo)&
									" "&ASU.To_String(Text),Pantalla.Verde);
			when CM.Logout =>	
					Debug.Put("FLOOD Logout ",Pantalla.Amarillo);
					Debug.Put_Line(ASU.To_String(Handlers.Print_EP(EP_H_Creat)) & CM.Seq_N_T'Image(Seq_N) &" "& 
						ASU.To_String(Handlers.Print_EP(EP_H_Rsnd))&" "&ASU.To_String(Handlers.Apodo)&
									" "&Boolean'Image(Confirm_Sent),Pantalla.Verde);
		end case;
			
		Handlers.Latest_Msgs.Put(Handlers.Lista_Mensajes, Handlers.EP_H, Seq_N,Success);
		Handlers.Array_Vecinos:=Handlers.Neighbors.Get_Keys(Handlers.Lista_Vecinos);
		L:=1;
		While Handlers.Array_Vecinos(L)/=null loop
			Debug.Put_Line("        send to: " & ASU.To_String(Handlers.Print_EP(Handlers.Array_Vecinos(L))),Pantalla.Verde);
			LLU.Send(Handlers.Array_Vecinos(L), Buffer'Access); -- envia apodo y end point a server
			L:=L+1;
		end loop;
		T_IO.New_Line;
		
	end Enviar_Mensaje;
	
	Puerto: Integer;
	Maquina: ASU.Unbounded_String;
	Maquina_Vecino_1: ASU.Unbounded_String;
	Puerto_Vecino_1 : Integer;
	Dir_IP_1:ASU.Unbounded_String;
	Maquina_Vecino_2: ASU.Unbounded_String;
	Puerto_Vecino_2 : Integer;
	Dir_IP_2:ASU.Unbounded_String;
	Vecino_1_EP:LLU.End_Point_Type;
	Vecino_2_EP:LLU.End_Point_Type;
	Dir_IP:ASU.Unbounded_String;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Expired : Boolean;
	EP_R:LLU.End_Point_Type;
	Mensaje_Tipo : CM.Message_Type;
	EP_H_Creat:LLU.End_Point_Type;
	Seq_N:CM.Seq_N_T;
	EP_H_Rsnd:LLU.End_Point_Type;
	EP_R_Creat:LLU.End_Point_Type;
	Nick:ASU.Unbounded_String;
	Hay_Vecinos:Boolean:=False;
	Success :Boolean;
	Confirm_Sent:Boolean:=False;
	Mensaje :ASU.Unbounded_String;
	Text:ASU.Unbounded_String;
	EP_H_Reject:LLU.End_Point_Type;
	Nick_Reject :ASU.Unbounded_String;
	Estado:Boolean;
	Prom:Boolean;
	Deb:Boolean;
	Usage_Error   : exception;
	
begin
	
	if Ada.Command_Line.Argument_Count <2 or Ada.Command_Line.Argument_Count=3 or 
			Ada.Command_Line.Argument_Count=5 or Ada.Command_Line.Argument_Count >6 then
				raise Usage_Error;
	end if;
	Puerto := Integer'Value (Ada.Command_Line.Argument(1)); --puerto en el que escucha
	Handlers.Apodo:=ASU.To_Unbounded_String (Ada.Command_Line.Argument(2));  --apodo maquina
	Debug.Asigna_Nombre(Handlers.Apodo);--ASIGNA EL NOMBRE A LA VARIABLE NOMBRE DEL DEBUG PARA USARLA EN EL .PROMPT
	Maquina := ASU.To_Unbounded_String (LLU.Get_Host_Name);
	Dir_IP := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina)));
	Handlers.EP_H := LLU.Build(ASU.To_String(Dir_IP), Puerto);-----------EP de la maquina
		
	if Ada.Command_Line.Argument_Count > 2 then 
		Maquina_Vecino_1:= ASU.To_Unbounded_String (Ada.Command_Line.Argument(3)); 
		Puerto_Vecino_1 := Integer'Value  (Ada.Command_Line.Argument(4));  
		Dir_IP_1 := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina_Vecino_1)));
		Vecino_1_EP := LLU.Build(ASU.To_String(Dir_IP_1), Puerto_Vecino_1);-----------EP del vecino 1º
		Handlers.Neighbors.Put(Handlers.Lista_Vecinos, Vecino_1_EP, Ada.Calendar.Clock,Success);------------------NEIGHBORS
		Hay_Vecinos:=True;
		Debug.Put_Line("Añadimos a neighbors "& ASU.To_String(Handlers.Print_EP(Vecino_1_EP)),Pantalla.Verde);
		
		if Ada.Command_Line.Argument_Count > 4 then 
			Maquina_Vecino_2 :=ASU.To_Unbounded_String (Ada.Command_Line.Argument(5)); 
			Puerto_Vecino_2 := Integer'Value  (Ada.Command_Line.Argument(6));  
			Dir_IP_2 := ASU.To_Unbounded_String (LLU.To_IP(ASU.To_String(Maquina_Vecino_2)));
			Vecino_2_EP := LLU.Build(ASU.To_String(Dir_IP_2), Puerto_Vecino_2);-----------EP del vecino 2º
			Handlers.Neighbors.Put(Handlers.Lista_Vecinos, Vecino_2_EP, Ada.Calendar.Clock,Success);-----------------NEIGHBORS
			Debug.Put_Line("Añadimos a neighbors "& ASU.To_String(Handlers.Print_EP(Vecino_2_EP)),Pantalla.Verde);
		end if;
	end if;
	
	
	
	LLU.Bind_Any(EP_R);
	LLU.Bind(Handlers.EP_H,Handlers.Peer_Handler'Access);

	if not Hay_Vecinos then
		Debug.Put_Line("NO hacemos protocolo de admision pues no tenemos contactos iniciales ...",Pantalla.Verde);
		Seq_N:= 0;
	else
		------------------MENSAJE INICIAL--------Protocolo de  admision-------------
		T_IO.New_Line;
		Debug.Put_Line("Iniciando Protocolo de Admisión ... ",Pantalla.Verde);
		
		Mensaje_Tipo:=CM.Init;
		EP_H_Creat:= Handlers.EP_H;
		Seq_N:= 1;
		EP_H_Rsnd:= Handlers.EP_H;
		EP_R_Creat:= EP_R;
		Nick := Handlers.Apodo;
		Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text);								
		-------Espera a recibir MENSAJE REJECT-----------------------
		LLU.Reset(Buffer);
		LLU.Receive (EP_R, Buffer'Access, 2.0, Expired);
		if Expired then
			--------------------------EVIA MENSAJE CONFIRM----------------
			Mensaje_Tipo:=CM.Confirm;
			EP_H_Creat:= Handlers.EP_H;
			Seq_N:= Seq_N+1;
			EP_H_Rsnd:= Handlers.EP_H;
			Nick := Handlers.Apodo;
			Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text);
		else
			----recibe reject--------
			Mensaje_Tipo:= CM.Message_Type'Input (Buffer'Access);
			EP_H_Reject:=LLU.End_Point_Type'Input (Buffer'Access);
			Nick_Reject :=ASU.Unbounded_String'Input(Buffer'Access);
			
			Debug.Put("RCV Reject ",Pantalla.Amarillo);
			Debug.Put_Line(ASU.To_String(Handlers.Print_EP(EP_H_Reject))& " "&ASU.To_String(Nick),Pantalla.Verde);
			T_IO.Put_Line("Usuario rechazado porque "&ASU.To_String( Handlers.Print_EP(EP_H_Reject))&" esta usando el mismo nick");
			-----------------------ENVIA MENSAJE  LOGOUT ----------------------
			Mensaje_Tipo:=CM.Logout;
			EP_H_Creat:= Handlers.EP_H;
			Seq_N:= Seq_N+1;
			EP_H_Rsnd:= Handlers.EP_H;
			Nick := Handlers.Apodo;
			Confirm_Sent:=False;
			Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text);
			Debug.Put_Line("Fin del Protocolo de Admisión.",Pantalla.Verde);
			LLU.Finalize;
			return;
		end if;
		Debug.Put_Line("Fin del Protocolo de Admisión.",Pantalla.Verde);
		T_IO.New_Line;
	end if;
	
	T_IO.Put_Line("Peer-Chat v1.0");
	T_IO.Put_Line("==============");	
	T_IO.New_Line;
	T_IO.Put_Line("Entramos en el chat con Nick: "&ASU.To_String(Handlers.Apodo));
	T_IO.Put_Line(".h para help");
			
	loop
		Prom:=Prompt.Get_Status;
		Deb:=Debug.Get_Status;
		if Prom=True and Deb = False then
			T_IO.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ");
			
		end if;
		Mensaje := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
		
		if ASU.To_String (Mensaje)=".nb" or ASU.To_String (Mensaje)=".neighbors" then
			-------------pinta los mapas vecinos y mensajes:::::::prueba--------------	
			Pantalla.Poner_Color (Pantalla.Rojo);
			T_IO.Put_Line("              Neighbors");
			T_IO.Put_Line("              -------------------");
			Handlers.Neighbors.Print_Map(Handlers.Lista_Vecinos);
			Pantalla.Poner_Color (Pantalla.Blanco);----------------------NO SE SI SE PUEDE HACER ASI O SE DEBE PONER POR DEFECTO-----------
	
		elsif ASU.To_String (Mensaje)=".lm" or ASU.To_String (Mensaje)=".latest_msgs" then
			----------------NEIGHBORS
			Pantalla.Poner_Color (Pantalla.Rojo);
			T_IO.Put_Line("              Latest_Msgs");
			T_IO.Put_Line("              -------------------");
			Handlers.Latest_Msgs.Print_Map(Handlers.Lista_Mensajes);
			Pantalla.Poner_Color (Pantalla.Blanco);
		
		elsif ASU.To_String (Mensaje)=".wai" or ASU.To_String (Mensaje)=".whoami" then
	
			Pantalla.Poner_Color (Pantalla.Rojo);
			T_IO.Put_Line("Nick: "&ASU.To_String(Handlers.Apodo)&" | EP_H: "&
						ASU.To_String(Handlers.Print_EP(Handlers.EP_H))&" | EP_R: "&ASU.To_String(Handlers.Print_EP(EP_R)));
			Pantalla.Poner_Color (Pantalla.Blanco);
		
		elsif ASU.To_String (Mensaje)=".prompt" then
		
			Estado:=Prompt.Get_Status;
			if Estado = True then
				Pantalla.Poner_Color (Pantalla.Rojo);
				T_IO.Put_Line("Desactivado el Prompt");
				Pantalla.Poner_Color (Pantalla.Blanco);
				Prompt.Set_Status(False);
			else 
				Prompt.Set_Status(True);
				Pantalla.Poner_Color(Pantalla.Rojo);
				T_IO.Put_Line("Activado el Prompt");
				Pantalla.Poner_Color(Pantalla.Blanco);
				Deb:=Debug.Get_Status;
				if Deb =True then
					Prompt.Put_Line(ASU.To_String(Handlers.Apodo)&" >> ",Pantalla.Blanco);
				end if;
				
			end if;
			
		elsif ASU.To_String (Mensaje)=".salir" then
		
			Mensaje_Tipo:=CM.Logout;
			EP_H_Creat:= Handlers.EP_H;
			Seq_N:= Seq_N+1;
			EP_H_Rsnd:= Handlers.EP_H;
			Nick := Handlers.Apodo;
			Confirm_Sent:=True;
			
			Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text);
			LLU.Finalize;
			return;
			
		elsif ASU.To_String (Mensaje)=".debug" then
		
			Estado:=Debug.Get_Status;
			if Estado = True then
				Pantalla.Poner_Color(Pantalla.Rojo);
				T_IO.Put_Line("Desactivada información de debug");
				Pantalla.Poner_Color(Pantalla.Blanco);
				Debug.Set_Status(False);
			else 
				Debug.Set_Status(True);
				Debug.Put_Line("Activada información de debug",Pantalla.Rojo);
			end if;
			
		elsif ASU.To_String (Mensaje)=".h" or ASU.To_String (Mensaje)=".help" then
		
			Pantalla.Poner_Color (Pantalla.Rojo);
			T_IO.Put_Line("              Comandos            Efectos");
			T_IO.Put_Line("              =================   =======");
			T_IO.Put_Line("              .nb .neighbors      lista de vecinos");
			T_IO.Put_Line("              .lm .latest_msgs    lista de últimos mensajes recibidos");
			T_IO.Put_Line("              .debug              toggle para info de debug");
			T_IO.Put_Line("              .wai .whoami        Muestra en pantalla: nick | EP_H | EP_R");
			T_IO.Put_Line("              .prompt             toggle para mostrar prompt");
			T_IO.Put_Line("              .h .help            muestra esta información de ayuda");
			T_IO.Put_Line("              .salir              termina el programa");
			Pantalla.Poner_Color (Pantalla.Blanco);

		else 
			----------------------ENVIA MENSAJE  WRITER ----------------------
			Mensaje_Tipo:=CM.Writer;
			EP_H_Creat:= Handlers.EP_H;
			Seq_N:= Seq_N+1;
			EP_H_Rsnd:= Handlers.EP_H;
			Nick := Handlers.Apodo;
			Text := Mensaje;
			Enviar_Mensaje (Mensaje_Tipo,EP_H_Creat,Seq_N,EP_H_Rsnd,EP_R_Creat,Nick,Confirm_Sent,Text);
		end if;
	
	end loop;
exception
	when Usage_Error =>
		Ada.Text_IO.Put_Line ("Uso: ./chat_peer port nick [[host port] [host port]]");
		LLU.Finalize;
	when Ex:others =>
		Pantalla.Poner_Color(Pantalla.Rojo);
		Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
		Pantalla.Poner_Color(Pantalla.Blanco);
		LLU.Finalize;
	
end Chat_Peer;