--Alfonso Nombela Moreno
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Calendar;

package body Users is
	
	procedure Mensaje_Hora(Lista: in Clients;
						Posicion: in  Integer;
						Mensaje_EP_H : in LLU.End_Point_Type) is
		h:Integer;
	begin
		h:=0;
		loop
			h:=h+1;
			if Clientes(h).EP= Mensaje_EP_H then
				Clientes(h).Hora:= Ada.Calendar.Clock;
			end if;
		exit when h=Posicion;
		end loop;
	end Mensaje_Hora;
	
	procedure Busca_Nicks (Lista: in Clients;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Nick:  in out ASU.Unbounded_String;
						Posicion: in out Integer) is
		I:Integer;
	begin
		I:=0;
		loop
			
			I:=I+1;
			if Clientes(I).EP= Mensaje_EP_H then 
				 Nick:= Clientes(I).Apodo;
				
			end if;
		exit when I= Posicion;
		end loop;
	end Busca_Nicks;
	
	procedure Insertar(Lista: in out Clients;
					Client_EP_Handler: in LLU.End_Point_Type;
                                          Nick : in ASU.Unbounded_String; 
                                          Posicion : in out Integer;
					  Acogido: out Boolean;
					  Max_Clients:in Integer) is
		I:Integer;
		
	begin	
			if Posicion>Max_Clients then
				Posicion:=Posicion;
			else
				Posicion:=Posicion+1;
			end if;
		I:=0;	
		loop-- bucle para comprobar los nicks
			I:=I+1;
			if ASU.To_String(Clientes(I).Apodo) = ASU.To_String(Nick) then 
				Acogido:=False;
				Posicion:=Posicion-1;
				exit;
			else
				Acogido:=True;
				
			end if;
		exit when I=Posicion;
		end loop;
		if Acogido=True then
			Clientes(Posicion).EP := Client_EP_Handler;
			Clientes(Posicion).Apodo:= Nick;
			
		end if;
	end insertar;
	
	procedure Mens_Server (Lista: in Clients;
						Mensaje_Tipo : in out CM.Message_Type;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Mensaje_Comentario:  in out ASU.Unbounded_String;
						Mensaje_Nick:  in out ASU.Unbounded_String;
						Posicion: in out Integer) is
		I:Integer;
		Nick:ASU.Unbounded_String;
		Buffer:    aliased LLU.Buffer_Type(1024);
	begin
		Busca_Nicks(Lista,Mensaje_EP_H,Nick,Posicion);
		
		if Mensaje_Tipo=CM.Writer then --combrueba si lo anterior era mensaje de salida o de escritor
			Mensaje_Nick:=Nick;
		elsif Mensaje_Tipo=CM.Init then
			Mensaje_Nick := ASU.To_Unbounded_String("servidor");
			Mensaje_Comentario:=ASU.TO_Unbounded_String(ASU.To_String(Nick)&" ha entrado en el chat");
		else
			Mensaje_Nick := ASU.To_Unbounded_String("servidor");
			Mensaje_Comentario:=ASU.TO_Unbounded_String(ASU.To_String(Nick)&" ha abandonado el chat");
		end if;
		I:=0;
		loop-- bucle para enviar mensajes servidores
			
			I:=I+1;
			if Clientes(I).EP/= Mensaje_EP_H and  ASU.To_String(Nick)/=ASU.To_String(Clientes_Vacio(1).Apodo) then
				
				LLU.Reset (Buffer);
				Mensaje_Tipo:=CM.Server;
				CM.Message_Type'Output(Buffer'Access,Mensaje_Tipo);
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje_Nick);
				ASU.Unbounded_String'Output (Buffer'Access, Mensaje_Comentario);
				LLU.Send (Clientes(I).EP, Buffer'Access);-- envía el contenido del Buffer
						
			end if;
						
		exit when I= Posicion;
		end loop;
		
	
	end Mens_Server;
	
	procedure Borrar_Cliente(Lista: in out Clients;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Posicion: in out Integer) is
		Vacio: Boolean;				
		I:Integer;	
		C:Integer;	
	begin
		Vacio:=False;
		if Posicion=1 then 
			Clientes:=Clientes_Vacio;
			Vacio:=True;
		end if;
		I:=0;
		while not Vacio loop
			I:=I+1;
			if Clientes(I).EP= Mensaje_EP_H then 
				C:=I;
				while  C< Posicion loop
					Clientes(C):=Clientes(C+1);
					C:=C+1;
				end loop;
				Clientes(Posicion):=Clientes_Vacio(1);
			end if;
		exit when I= Posicion;
		end loop;
		Posicion:=Posicion-1;
	end Borrar_Cliente;
	
	procedure Expulsar_Cliente(Lista: in out Clients;
						    Posicion: in out Integer;
						    Mensaje_EP_H : in LLU.End_Point_Type;
						    Mensaje_Tipo : in out CM.Message_Type;
						    Mensaje_Comentario:  in out ASU.Unbounded_String;
						    Mensaje_Nick:  in out ASU.Unbounded_String;
						    Max_Clients:in Integer) is
		h:Integer;
		
		Expulso:Integer;
		Hora_Actual:Ada.Calendar.Time;
		Mayor_Tiempo: Duration:=0.0;
		Buffer:    aliased LLU.Buffer_Type(1024);
	begin
		Hora_Actual:=Ada.Calendar.Clock;
		Mayor_Tiempo:=0.0;
		if Posicion >Max_Clients then
			h:=0;
			loop
				h:=h+1;
				if (Hora_Actual-Clientes(h).Hora) >Mayor_Tiempo then	
	
					Mayor_Tiempo:= (Hora_Actual-Clientes(h).Hora) ;
				end if;
			exit when h=Posicion-1;
			end loop;
			h:=0;
			loop
				h:=h+1;
				if Mayor_Tiempo= (Hora_Actual-Clientes(h).Hora) then	
					Expulso:=h;
					Mensaje_Nick := ASU.To_Unbounded_String("servidor");
					Mensaje_Comentario:=ASU.TO_Unbounded_String(ASU.To_String(Clientes(h).Apodo)&" ha sido expulsado del chat.");
						
				end if;
			
			exit when h=Posicion-1;
			end loop;
			h:=0;
			loop
				h:=h+1;
				LLU.Reset (Buffer);
				Mensaje_Tipo:=CM.Server;
				CM.Message_Type'Output(Buffer'Access,Mensaje_Tipo);
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje_Nick);
				ASU.Unbounded_String'Output (Buffer'Access, Mensaje_Comentario);
				LLU.Send (Clientes(h).EP, Buffer'Access);-- envía el contenido del Buffer
			exit when h=Posicion;
			end loop ;
			Clientes(Expulso):=Clientes(Posicion);
			Clientes(Posicion):=Clientes_Vacio(1);
			Posicion:=Posicion-1;
				
		end if;
	end Expulsar_Cliente;
	
end Users;