--Alfonso Nombela Moreno
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Calendar;
with Ada.Unchecked_Deallocation;

package Users is

	type Clients is private;
   
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	use type Ada.Calendar.Time;
	use Type LLU.End_Point_Type;
	
	procedure Mensaje_Hora(Lista: in Clients;
						Posicion: in  Integer;
						Mensaje_EP_H : in LLU.End_Point_Type);
						
	procedure Busca_Nicks (Lista: in Clients;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Nick:  in out ASU.Unbounded_String;
						Posicion: in out Integer) ;

	procedure Insertar(Lista: in Out Clients;
					Client_EP_Handler: in  LLU.End_Point_Type;
                                          Nick : in  ASU.Unbounded_String; 
                                          Posicion : in out Integer;
					  Acogido: out Boolean;
					  Max_Clients:in Integer);
					  
	procedure Mens_Server (Lista: in Clients;
						Mensaje_Tipo : in out CM.Message_Type;
						Mensaje_EP_H: in  LLU.End_Point_Type;
						Mensaje_Comentario:  in out ASU.Unbounded_String;
						Mensaje_Nick:  in out ASU.Unbounded_String;
						Posicion: in out Integer) ;
						
	procedure Borrar_Cliente(Lista: in out Clients;
						Mensaje_EP_H: in   LLU.End_Point_Type;
						Posicion: in out Integer) ;
						
	procedure Expulsar_Cliente(Lista: in out Clients;
							Posicion: in out Integer;
						    Mensaje_EP_H : in LLU.End_Point_Type;
						    Mensaje_Tipo : in out CM.Message_Type;
						    Mensaje_Comentario:  in out ASU.Unbounded_String;
						    Mensaje_Nick:  in out ASU.Unbounded_String;
						    Max_Clients:in Integer) ;

private
	type Clientes;
	type Clients is access Clientes;

	type Clientes is record
		EP: LLU.End_Point_Type;
		Apodo: ASU.Unbounded_String;
		Hora:Ada.Calendar.Time;
		Siguiente :Clients;
	end record;
	
end Users;