--Alfonso Nombela Moreno
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Calendar;
with Ada.Unchecked_Deallocation;

package body Users is

	procedure Free is new Ada.Unchecked_Deallocation (Clientes,  Clients);
	----MIRA SI LISTA VACIA:PUNTEROS--------
	function EsListaVacia ( list:  Clients) return Boolean is 
	
	begin
		return list = null;
	end;
	
	procedure Mensaje_Hora(Lista: in Clients;
						Posicion: in  Integer;
						Mensaje_EP_H : in LLU.End_Point_Type) is
		P_Lista: Clients;
	begin
		P_Lista := Lista;
		while  not EsListaVacia(P_Lista) loop
			
			if P_Lista.EP= Mensaje_EP_H then
				P_Lista.Hora:= Ada.Calendar.Clock;
			end if;
		P_Lista:=P_Lista.Siguiente;
		end loop;
	end Mensaje_Hora;
	
	procedure Busca_Nicks (Lista: in Clients;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Nick:  in out ASU.Unbounded_String;
						Posicion: in out Integer) is
		P_Lista: Clients;
	begin
		
		P_Lista := Lista;
		while  not EsListaVacia(P_Lista)loop
			
			if P_Lista.EP= Mensaje_EP_H then ---solucionar por que no entra
				 Nick:= P_Lista.Apodo;
				
			end if;
			P_Lista:=P_Lista.Siguiente;
		end loop;
	end Busca_Nicks;
	
	procedure Insertar(Lista:in out Clients;
					Client_EP_Handler: in LLU.End_Point_Type;
                                          Nick : in ASU.Unbounded_String; 
                                          Posicion : in out Integer;
					  Acogido: out Boolean;
					  Max_Clients:in Integer) is
		P_Lista: Clients;
		
	begin	
		if Posicion>Max_Clients then
			Posicion:=Posicion;
		else
			Posicion:=Posicion+1;
		end if;
		P_Lista := Lista;
		if EsListaVacia(P_Lista) then 
			Acogido:=True;
		end if;
		while  not EsListaVacia(P_Lista) loop-- bucle para comprobar los nicks
			
			if ASU.To_String(P_Lista.Apodo) = ASU.To_String(Nick) then 
				
				Posicion:=Posicion-1;
				exit;
			else 
				Acogido:=True;
			end if;
			P_Lista:=P_Lista.Siguiente;
		end loop;
		
		if Acogido then
			P_Lista:= new Clientes;
			P_Lista.EP := Client_EP_Handler;
			P_Lista.Apodo:= Nick;
			P_Lista.Siguiente := Lista;
			Lista := P_Lista;
		end if;
	end insertar;
	
	procedure Mens_Server (Lista: in  Clients;
						Mensaje_Tipo : in out CM.Message_Type;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Mensaje_Comentario:  in out ASU.Unbounded_String;
						Mensaje_Nick:  in out ASU.Unbounded_String;
						Posicion: in out Integer) is
		P_Lista: Clients;
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
		P_Lista := Lista;
		while  not EsListaVacia(P_Lista)loop-- bucle para enviar mensajes servidores
			
			if P_Lista.EP/= Mensaje_EP_H then
				
				LLU.Reset (Buffer);
				Mensaje_Tipo:=CM.Server;
				CM.Message_Type'Output(Buffer'Access,Mensaje_Tipo);
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje_Nick);
				ASU.Unbounded_String'Output (Buffer'Access, Mensaje_Comentario);
				LLU.Send (P_Lista.EP, Buffer'Access);-- envía el contenido del Buffer
						
			end if;
			P_Lista:=P_Lista.Siguiente;			
		end loop;
		
	end Mens_Server;
	
	procedure Borrar_Cliente(Lista: in out Clients;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Posicion: in out Integer) is
		Vacio: Boolean;				
		P_Lista: Clients;
		P_List: Clients;
		
	begin
		
		P_Lista:=Lista;
		P_List:=Lista;
		
		if Posicion=1 then 
			Free(P_Lista);
			Vacio:=True;
			
		end if;

		while not Vacio and not EsListaVacia(P_List) loop
				
			if Lista.EP= Mensaje_EP_H then 
				
				P_Lista:=P_List;
				P_List:=P_List.Siguiente;	
				Free(P_Lista);
				exit;
				
			end if;
		P_List:=P_List.Siguiente;
	
		end loop;
		Lista := P_List;
		Posicion:=Posicion-1;
		
	end Borrar_Cliente;
	
	procedure Expulsar_Cliente(Lista: in out Clients;
						    Posicion: in out Integer;
						    Mensaje_EP_H : in LLU.End_Point_Type;
						    Mensaje_Tipo : in out CM.Message_Type;
						    Mensaje_Comentario:  in out ASU.Unbounded_String;
						    Mensaje_Nick:  in out ASU.Unbounded_String;
						    Max_Clients:in Integer) is
		P_Lista: Clients;
		Hora_Actual:Ada.Calendar.Time;
		Mayor_Tiempo: Duration:=0.0;
		Buffer:    aliased LLU.Buffer_Type(1024);
	begin
		
		Hora_Actual:=Ada.Calendar.Clock;
		Mayor_Tiempo:=0.0;
		if Posicion >Max_Clients then
			P_Lista:=Lista;
			while not EsListaVacia(P_Lista) loop
			
				if (Hora_Actual-P_Lista.Hora) >Mayor_Tiempo then	
	
					Mayor_Tiempo:= (Hora_Actual-P_Lista.Hora) ;
				end if;
				P_Lista:=P_Lista.Siguiente;
			end loop;
			P_Lista:=Lista;
			while not EsListaVacia(P_Lista) loop
				
				if Mayor_Tiempo= (Hora_Actual-P_Lista.Hora) then	
					
					Mensaje_Nick := ASU.To_Unbounded_String("servidor");
					Mensaje_Comentario:=ASU.TO_Unbounded_String(ASU.To_String(P_Lista.Apodo)&" ha sido expulsado del chat.");
						Borrar_Cliente(Lista,Mensaje_EP_H,Posicion);
				end if;
				
				P_Lista:=P_Lista.Siguiente;
			end loop;
			P_Lista:=Lista;
			while not EsListaVacia(P_Lista) loop
				
				LLU.Reset (Buffer);
				Mensaje_Tipo:=CM.Server;
				CM.Message_Type'Output(Buffer'Access,Mensaje_Tipo);
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje_Nick);
				ASU.Unbounded_String'Output (Buffer'Access, Mensaje_Comentario);
				LLU.Send (P_Lista.EP, Buffer'Access);-- envía el contenido del Buffer
			P_Lista:=P_Lista.Siguiente;
			end loop ;
			
		end if;
	end Expulsar_Cliente;
	
end Users;