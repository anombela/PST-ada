with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Ada.IO_Exceptions;

procedure Chat_Server is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	use Type LLU.End_Point_Type;
	----array
	type Clients is record
		EP: LLU.End_Point_Type;
		Apodo: ASU.Unbounded_String;
	end record;
	Clientes : array (1..50) of Clients;
	
	Server_EP: LLU.End_Point_Type;
	Buffer:    aliased LLU.Buffer_Type(1024);
	Expired : Boolean;
	Puerto: Integer;
	Mens:CM.Mensaje;
	Nombre: ASU.Unbounded_String;
	N:Integer:=0;
	I:Integer;
	Fin:Boolean:=False;
	
begin

	-- construye un End_Point en una dirección y puerto concretos
	Puerto := Integer'Value (Ada.Command_Line.Argument(1)); --puerto en el que escucha
	
	if Ada.Command_Line.Argument_Count > 1  then -- acaba la ejecucion si se meten argumentos de mas en la linea de comandos
		Ada.Text_IO.Put_Line ("Demasiados argumentos en la linea de comandos.");
		Fin := True;
	end if;
	
	if Puerto <1024 then --acaba la ejecucion si se utiliza un puerto reservado
		Ada.Text_IO.Put_Line ("Puerto introducido reservado. Intruducir uno mayor de 1023.");
		Fin := True;
	else
		Server_EP := LLU.Build ("127.0.0.1", Puerto);
		LLU.Bind (Server_EP);-- se ata al End_Point para poder recibir en él
	end if;
	
	--se entra en  bucle infinito cuando se cumplan las condiciones de arriba
	while Fin = False loop
	
		LLU.Reset(Buffer);
		LLU.Receive (Server_EP, Buffer'Access, 1000.0, Expired);
		if Expired then
			Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo.");
		else
			Mens:= CM.Mensaje'Input (Buffer'Access);
			if Mens.Tipo=CM.Init then
				N:=N+1;
				Ada.Text_IO.Put_Line ("recibido mensaje inicial de " &ASU.To_String(Mens.Nick));
				Clientes(N).EP := Mens.EP;
				Clientes(N).Apodo:= Mens.Nick;	
			else
				I:=0;
				loop-- bucle para recibir mensaje y asignarle un nick
					I:=I+1;
					if Clientes(I).EP = Mens.EP then 
						Nombre:=Clientes(I).Apodo;
						Ada.Text_IO.Put ("recibido mensaje de " & ASU.To_String(Nombre) &": ");
						Ada.Text_IO.Put_Line (ASU.To_String(Mens.Comentario));
					
					end if;
					
				exit when I= N;
				end loop;	
			
				I:=0;
				loop-- bucle para enviar a los lectores
				
					I:=I+1;
					if ASU.To_String(Clientes(I).Apodo)= "lector" then 
						
						LLU.Reset (Buffer);
						Mens.Nick:=Nombre;
						Mens.Tipo:=CM.Server;
						CM.Mensaje'Output (Buffer'Access, Mens);
						LLU.Send (Clientes(I).EP, Buffer'Access);-- envía el contenido del Buffer
						
					end if;
						
				exit when I= N;
				end loop;
				
			end if;
		
		end if;
	end loop;

	LLU.Finalize;
exception
	
	when CONSTRAINT_ERROR =>
		Ada.Text_IO.Put_Line ("Puerto introducido no valido o no introducido.");
		LLU.Finalize;
	
	

end Chat_Server;