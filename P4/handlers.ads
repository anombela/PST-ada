--Alfonso Nombela MorenO

with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Maps_G;
with Lower_Layer_UDP;
with Ada.Calendar;
with Time_String;
with Maps_Protector_G;
with Chat_Messages;
with Pantalla;
with Debug;
with Prompt;

package Handlers is

	package ASU  renames Ada.Strings.Unbounded;
	package T_IO renames Ada.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;
	use Type CM.Message_Type;
	use type ASU.Unbounded_String;
	use Type LLU.End_Point_Type;
	
	use type CM.Seq_N_T;
	
	package NP_Neighbors is new Maps_G (Key_Type   => LLU.End_Point_Type,
								Value_Type => Ada.Calendar.Time,
								Null_Key=> null,
								Null_Value=> Ada.Calendar.Time_Of(2000,1,1),----1 de enero de 2000, a las 00:00h.
								Max_Length=>10,
								"="        => LLU."=",
								Key_To_String  => LLU.Image,
								Value_To_String  => Time_String.Image);----paquete que devuelve hora
			       
	package Neighbors is new Maps_Protector_G (NP_Neighbors);
	
	package NP_Latest_Msgs is new Maps_G (Key_Type   => LLU.End_Point_Type,
								Value_Type => CM.Seq_N_T,
								Null_Key=> null,
								Null_Value=> 0,----1 de enero de 2000, a las 00:00h.
								Max_Length=>50,
								"="        => LLU."=",
								Key_To_String  => LLU.Image,
								Value_To_String  => CM.Seq_N_T'Image);----paquete que devuelve hora
			       
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
	
	Lista_Vecinos:Neighbors.Prot_Map;----importante como se pone el prot_map
	Array_Vecinos:Neighbors.Keys_Array_Type;
	Lista_Mensajes:Latest_Msgs.Prot_Map;
	A_M_Valores:Latest_Msgs.Values_Array_Type;
	A_M_EPs:Latest_Msgs.Keys_Array_Type;
	Apodo: ASU.Unbounded_String;
	EP_H:LLU.End_Point_Type;
	
	function Print_EP (EP:LLU.End_Point_Type) return ASU.Unbounded_String;----------------procedimiento nuevo
	
	procedure Enviar_Mensaje (Mensaje_Tipo : CM.Message_Type;
						EP_H_Creat:LLU.End_Point_Type;
						Seq_N:CM.Seq_N_T;
						EP_H_Rsnd:LLU.End_Point_Type;
						EP_R_Creat:LLU.End_Point_Type;
						Nick:ASU.Unbounded_String;
						Confirm_Sent:Boolean;
						Text:ASU.Unbounded_String;
						EP_H_Reenvio:LLU.End_Point_Type) ;
	
	procedure Peer_Handler (From     : in     LLU.End_Point_Type;
                           To       : in     LLU.End_Point_Type;
                           P_Buffer : access LLU.Buffer_Type);
			   
end Handlers;