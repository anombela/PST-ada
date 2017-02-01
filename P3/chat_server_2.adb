--Alfonso Nombela Moreno

--CONSIDERO QUE AL EXPULSAR A UN CLIENTE, ESTE DEBE SALIR DEL CHAT
--CON CTRL+C. DEVIDO A QUE .SALIR SOLO ES PARA USUARIOS CONECTADOS.

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Ada.IO_Exceptions;
with Users;
with Ada.Calendar;

procedure Chat_Server_2 is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	use Type LLU.End_Point_Type;

	
	procedure Inicio_Servidor  (Port: out Integer; 
						 Max: out Integer;
						Ser_EP :out LLU.End_Point_Type;
						Finish : in out Boolean) is
	begin
		begin
		
		Port := Integer'Value (Ada.Command_Line.Argument(1)); --puerto en el que escucha el servidor
		Max := Integer'Value (Ada.Command_Line.Argument(2));
		
		if Ada.Command_Line.Argument_Count > 2 then -- acaba la ejecucion si se meten argumentos de mas en la linea de comandos
			Ada.Text_IO.Put_Line ("Demasiados argumentos en la linea de comandos.");
			Finish := True;
		end if;
		
		if Max <2 or Max >50 then
			Ada.Text_IO.Put_Line ("Numero máximo o minimo de clientes incorrecto");
			Finish := True;
		end if;
		if Port <1024 then --acaba la ejecucion si se utiliza un puerto reservado
			Ada.Text_IO.Put_Line ("Puerto introducido reservado. Intruducir uno mayor de 1023.");
			Finish := True;
		else
			Ser_EP := LLU.Build ("127.0.0.1", Port);
			LLU.Bind (Ser_EP);-- se ata al End_Point para poder recibir en él
		end if;
		exception
			when CONSTRAINT_ERROR =>
				Ada.Text_IO.Put_Line ("Incorrecto número de argumentos en la linea de comandos "& 
								"o incorrecta forma de introducirlos");
				Finish := True;
		end;
	
	end Inicio_Servidor;
	
	
	Server_EP: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Expired : Boolean;
	Fin : Boolean:=False;
	Puerto: Integer;
	Mensaje_Tipo : CM.Message_Type;
	Mensaje_EP_H: LLU.End_Point_Type;
	Mensaje_EP_R: LLU.End_Point_Type;
	Mensaje_Comentario: ASU.Unbounded_String;
	Mensaje_Nick: ASU.Unbounded_String;
	Mensaje_Acogido: Boolean;
	Nick: ASU.Unbounded_String;
	Posicion:Integer:=0;
	Acogido: Boolean;
	Max_Clients:Integer;
	Lista:Users.Clients;
	
	
begin

	Inicio_Servidor  (Puerto,Max_Clients,Server_EP,Fin);
	while  Fin=False loop
		LLU.Reset(Buffer);
		LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);
		if Expired then
			Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo.");
		else
			Mensaje_Tipo := CM.Message_Type'Input (Buffer'Access);
			if Mensaje_Tipo=CM.Init then
				----------RECIBE MENSAJE INICIAL-----------
				Mensaje_EP_R := LLU.End_Point_Type'Input (Buffer'Access);
				Mensaje_EP_H := LLU.End_Point_Type'Input (Buffer'Access);
				Mensaje_Nick := ASU.Unbounded_String'Input (Buffer'Access);
				Nick := Mensaje_Nick;
				Users.Insertar(Lista,Mensaje_EP_H, Nick, Posicion,Acogido,Max_Clients);
				if Acogido = True then 
					Ada.Text_IO.Put_Line ("recibido mensaje inicial de " &ASU.To_String(Nick) & ": ACEPTADO");
					Users.Mensaje_Hora(Lista,Posicion,Mensaje_EP_H);--almacena la hora
					Users.Mens_Server (Lista,Mensaje_Tipo, Mensaje_EP_H,Mensaje_Comentario,Mensaje_Nick,Posicion);
					Users.Expulsar_Cliente(Lista,Posicion,Mensaje_EP_H,Mensaje_Tipo ,Mensaje_Comentario,Mensaje_Nick,Max_Clients);
					
				else
					Ada.Text_IO.Put_Line ("recibido mensaje inicial de " &ASU.To_String(Nick) & ": RECHAZADO");
				end if;
				-------------ENVIA MENSAJE ACOGIDA-----------
				LLU.Reset(Buffer);
				Mensaje_Tipo:= CM.Welcome;
				CM.Message_Type'Output(Buffer'Access, Mensaje_Tipo);
				Mensaje_Acogido:=Acogido;     
				Boolean'Output(Buffer'Access, Mensaje_Acogido);
				LLU.Send(Mensaje_EP_R, Buffer'Access);-- envía el contenido del Buffer
				
			elsif Mensaje_Tipo=CM.Writer then
				----------RECIBE MENSAJE ESCRITOR----------
				Mensaje_EP_H := LLU.End_Point_Type'Input (Buffer'Access);
				Mensaje_Comentario := ASU.Unbounded_String'Input (Buffer'Access);
				Users.Mensaje_Hora(Lista,Posicion,Mensaje_EP_H);--alamacenala hora 
				
				--------MENSAJE SERVIDOR COMENTARIO-----------------
				Users.Mens_Server (Lista,Mensaje_Tipo, Mensaje_EP_H,Mensaje_Comentario,Mensaje_Nick,Posicion);
				Users.Busca_Nicks(Lista,Mensaje_EP_H,Nick,Posicion);
				Ada.Text_IO.Put_Line (("recibido mensaje de ")&ASU.To_String(Nick)&(": ")&ASU.To_String(Mensaje_Comentario));
				
			elsif Mensaje_Tipo=CM.Logout  then
				
					----------RECIBE MENSAJE SALIDA----------
					Mensaje_EP_H := LLU.End_Point_Type'Input (Buffer'Access);
				
					----------MENSAJE SERVIDOR SALIDA-----
					Users.Mens_Server (Lista,Mensaje_Tipo, Mensaje_EP_H,Mensaje_Comentario,Mensaje_Nick,Posicion);
					Users.Busca_Nicks(Lista,Mensaje_EP_H,Nick,Posicion);
					Ada.Text_IO.Put_Line ("recibido mensaje de salida de " & ASU.To_String(Nick));
					Users.Borrar_Cliente(Lista,Mensaje_EP_H, Posicion);------
			end if;
		end if;
	end loop;
	
	LLU.Finalize;
	
exception
	when Ex:others =>
			Ada.Text_IO.Put_Line ("Excepción imprevista: " &
				Ada.Exceptions.Exception_Name(Ex) & " en: " &
					Ada.Exceptions.Exception_Message(Ex));
		LLU.Finalize;
	
end Chat_Server_2;