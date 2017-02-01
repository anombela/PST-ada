--Alfonso Nombela Moreno
with Lower_Layer_UDP;

package Chat_Messages is

	type Message_Type is (Init, Reject, Confirm, Writer, Logout,Ack);
	type Seq_N_T is mod Integer'Last;
	
	package LLU renames Lower_Layer_UDP;
	type Buffer_A_T is access LLU.Buffer_Type;
	P_Buffer_Main: Buffer_A_T;
	P_Buffer_Handler: Buffer_A_T;


end Chat_Messages;
