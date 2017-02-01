--Alfonso Nombela Moreno
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Handlers;

procedure Chat_Client_2 is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	
	Server_EP: LLU.End_Point_Type;
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Mensaje:   ASU.Unbounded_String;
	Puerto: Integer;
	Nomb_Servi: ASU.Unbounded_String;
	Apodo: ASU.Unbounded_String;
	Fin:Boolean:=False;
	Expired : Boolean;
	Mensaje_Tipo : CM.Message_Type;
	Mensaje_EP_R: LLU.End_Point_Type;
	Mensaje_EP_H: LLU.End_Point_Type;
	Mensaje_Comentario: ASU.Unbounded_String;
	Mensaje_Nick: ASU.Unbounded_String;
	Mensaje_Acogido: Boolean;
	
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
	
		LLU.Bind_Any(Client_EP_Receive);
		LLU.Bind_Any(Client_EP_Handler,Handlers.Client_Handler'Access);
		
	------------------MENSAJE INICIAL---------------------
		LLU.Reset(Buffer);--resetea  para crear y mandar e mensaje inicial	
		Mensaje_Tipo:=CM.Init;
		CM.Message_Type'Output(Buffer'Access,Mensaje_Tipo);
		Mensaje_EP_R := Client_EP_Receive;
		LLU.End_Point_Type'Output(Buffer'Access, Mensaje_EP_R);
		Mensaje_EP_H := Client_EP_Handler;
		LLU.End_Point_Type'Output(Buffer'Access, Mensaje_EP_H);
		Mensaje_Nick := Apodo;
		ASU.Unbounded_String'Output(Buffer'Access, Mensaje_Nick);
		LLU.Send(Server_EP, Buffer'Access); -- envia apodo y end point a server
		
		--------RECIBE MENSAJE ACOGIDA-------------
		LLU.Reset(Buffer);
		LLU.Receive (Client_EP_Receive, Buffer'Access, 10.0, Expired);
		if Expired then
			Ada.Text_IO.Put_Line ("No es posible comunicarse con el servidor.");
		else
			
			Mensaje_Tipo := CM.Message_Type'Input (Buffer'Access);
			Mensaje_Acogido:= Boolean'Input (Buffer'Access);
			Ada.Text_IO.Put ("Mini-Chat v2.0: ");
			if Mensaje_Acogido=False then
				Ada.Text_IO.Put_Line ("Cliente rechazado porque el nickname "&
									ASU.To_String(Apodo)&" ya existe en el servidor.");
			else
				Ada.Text_IO.Put_Line("Bienvenido "&ASU.To_String(Apodo));
			end if;
		end if;
		
		while Mensaje_Acogido=True loop
			
			Ada.Text_IO.Put(">> ");
			Mensaje := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			if ASU.To_String(Mensaje) /= ".salir" then 
				---------------------MENSAJE ESCRITOR----------------
				LLU.Reset(Buffer);-- reinicializa el buffer para empezar a utilizarlo
				Mensaje_Tipo:= CM.Writer;
				CM.Message_Type'Output(Buffer'Access, Mensaje_Tipo);
				Mensaje_EP_H:=Client_EP_Handler;     -- crea el mensaje writer
				LLU.End_Point_Type'Output(Buffer'Access, Mensaje_EP_H);
				Mensaje_Comentario:=Mensaje;
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje_Comentario);
				LLU.Send(Server_EP, Buffer'Access);-- envía el contenido del Buffer
					
			end if;

		exit when   ASU.To_String(Mensaje) = ".salir";
		end loop;
		if  ASU.To_String(Mensaje) = ".salir" then
			-------MENSAJE SALIDA-----------
			LLU.Reset(Buffer);
			Mensaje_Tipo:= CM.Logout;
			CM.Message_Type'Output(Buffer'Access, Mensaje_Tipo);
			Mensaje_EP_H:=Client_EP_Handler;  
			LLU.End_Point_Type'Output(Buffer'Access, Mensaje_EP_H);
			LLU.Send(Server_EP, Buffer'Access);-- envía el contenido del Buffer	
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

end Chat_Client_2;