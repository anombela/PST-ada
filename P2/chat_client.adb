with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;

procedure Chat_Client is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	
	Server_EP: LLU.End_Point_Type;
	Client_EP: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Mensaje:   ASU.Unbounded_String;
	Expired : Boolean;
	Puerto: Integer;
	Maquina: ASU.Unbounded_String;
	Direc_IP: ASU.Unbounded_String;
	Nomb_Servi: ASU.Unbounded_String;
	Apodo: ASU.Unbounded_String;
	Mens_Inicial:CM.Mensaje;
	Mens_Escritor:CM.Mensaje;
	Mens_Servidor:CM.Mensaje;
	Fin:Boolean:=False;
	
 begin
	
	Nomb_Servi :=ASU.To_Unbounded_String (Ada.Command_Line.Argument(1));  --nombre de la maquina del servidor
	Puerto := Integer'Value (Ada.Command_Line.Argument(2)); --puerto en el que escucha
	Server_EP := LLU.Build ("127.0.0.1", Puerto);
	Apodo :=ASU.To_Unbounded_String (Ada.Command_Line.Argument(3));  --apodo maquina
	
	if Ada.Command_Line.Argument_Count > 3 then 
		Ada.Text_IO.Put_Line ("Demasiados argumentos en la linea de comandos");
		Fin := True;
	end if;
	if Fin = False then
		LLU.Bind_Any(Client_EP);-- Construye un End_Point libre cualquiera y se ata a él
	
		LLU.Reset(Buffer);--resetea  para crear y mandar e mensaje inicial
		Mens_Inicial.Tipo:=CM.Init;
		Mens_Inicial.EP := Client_EP;
		Mens_Inicial.Nick := Apodo;
		CM.Mensaje'Output(Buffer'Access, Mens_Inicial);
		LLU.Send(Server_EP, Buffer'Access); -- envia apodo y end point a server
	
		if ASU.To_String(Apodo) = "lector" then
			Ada.Text_IO.Put_Line("--Modo lector--");
			loop
		
				LLU.Reset(Buffer);
				LLU.Receive (Client_EP, Buffer'Access, 1000.0, Expired);

				if Expired then
					Ada.Text_IO.Put_Line ("Plazo expirado");
				else
			
					Mens_Servidor := CM.Mensaje'Input (Buffer'Access);
					Ada.Text_IO.Put (ASU.To_String(Mens_Servidor.Nick));
					Ada.Text_IO.Put(": ");
					Ada.Text_IO.Put_Line (ASU.To_String(Mens_Servidor.Comentario));
			
				end if;
			end loop;
		else
			loop
			
				LLU.Reset(Buffer);-- reinicializa el buffer para empezar a utilizarlo
			
				Ada.Text_IO.Put("Mensaje: ");
				Mensaje := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
	
				Mens_Escritor.Tipo:= CM.Writer;--
				Mens_Escritor.EP:=Client_EP;     -- crea el mensaje writer
				Mens_Escritor.Comentario:=Mensaje;--
			
				if ASU.To_String(Mensaje) /= ".salir" then 
			
					CM.Mensaje'Output(Buffer'Access, Mens_Escritor);
				LLU.Send(Server_EP, Buffer'Access);-- envía el contenido del Buffer
					
				end if;

			exit when   ASU.To_String(Mensaje) = ".salir";
			end loop;
		
		end if;
	end if;
	
	LLU.Finalize; 

	exception
		when CONSTRAINT_ERROR =>
			Ada.Text_IO.Put_Line ("Argumentos incorrectos en linea de comandos.");
			Ada.Text_IO.Put_Line ("Forma correcta: Maquina-Puerto-Nick.");
			LLU.Finalize; 
		when Ex:others =>
			Ada.Text_IO.Put_Line ("Excepción imprevista: " &
				Ada.Exceptions.Exception_Name(Ex) & " en: " &
					Ada.Exceptions.Exception_Message(Ex));
	LLU.Finalize;

end Chat_Client;
